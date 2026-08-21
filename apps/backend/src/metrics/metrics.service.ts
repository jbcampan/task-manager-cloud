import { Injectable } from '@nestjs/common';
import * as client from 'prom-client';

@Injectable()
export class MetricsService {
  readonly registry: client.Registry;
  readonly httpRequestDuration: client.Histogram<'method' | 'route' | 'status_code'>;
  readonly httpRequestsTotal: client.Counter<'method' | 'route' | 'status_code'>;

  constructor() {
    this.registry = new client.Registry();

    // Process-level metrics (CPU, memory, event loop lag, GC) - free from
    // prom-client, no manual instrumentation needed.
    client.collectDefaultMetrics({ register: this.registry });

    // RED method (Rate, Errors, Duration) - the standard starting point
    // for HTTP service observability, deliberately kept to these two
    // metrics rather than instrumenting every business operation
    // individually. `route` uses the matched Nest route pattern
    // (e.g. /tasks/:id), not the raw URL, to avoid unbounded label
    // cardinality from real task IDs - a well-known Prometheus pitfall.
    this.httpRequestDuration = new client.Histogram({
      name: 'http_request_duration_seconds',
      help: 'Duration of HTTP requests in seconds',
      labelNames: ['method', 'route', 'status_code'],
      buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
      registers: [this.registry],
    });

    this.httpRequestsTotal = new client.Counter({
      name: 'http_requests_total',
      help: 'Total number of HTTP requests',
      labelNames: ['method', 'route', 'status_code'],
      registers: [this.registry],
    });
  }
}
