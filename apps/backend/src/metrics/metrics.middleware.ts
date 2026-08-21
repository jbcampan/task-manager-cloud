import { Injectable, NestMiddleware } from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';

import { MetricsService } from './metrics.service';

@Injectable()
export class MetricsMiddleware implements NestMiddleware {
  constructor(private readonly metrics: MetricsService) {}

  use(req: Request, res: Response, next: NextFunction) {
    const start = process.hrtime.bigint();

    // Measured on the 'finish' event (headers sent) rather than wrapped
    // around next() - fires regardless of which guard, pipe, or
    // interceptor produced the response, including error responses from
    // the global exception filter.
    res.on('finish', () => {
      const durationSeconds = Number(process.hrtime.bigint() - start) / 1e9;
      // req.route is only populated once Express has matched a route -
      // falls back to the raw path for 404s, where no route ever matched.
      const route = req.route?.path ?? req.path;
      const labels = {
        method: req.method,
        route,
        status_code: String(res.statusCode),
      };
      this.metrics.httpRequestDuration.observe(labels, durationSeconds);
      this.metrics.httpRequestsTotal.inc(labels);
    });

    next();
  }
}
