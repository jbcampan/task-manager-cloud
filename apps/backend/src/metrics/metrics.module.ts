import { MiddlewareConsumer, Module, NestModule, RequestMethod } from '@nestjs/common';

import { MetricsController } from './metrics.controller';
import { MetricsMiddleware } from './metrics.middleware';
import { MetricsService } from './metrics.service';

@Module({
  controllers: [MetricsController],
  providers: [MetricsService],
  exports: [MetricsService],
})
export class MetricsModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    // Applied to every route except /metrics itself - otherwise each
    // Prometheus scrape would recursively inflate its own
    // http_request_duration_seconds histogram.
    consumer
      .apply(MetricsMiddleware)
      .exclude({ path: 'metrics', method: RequestMethod.GET })
      .forRoutes({ path: '*', method: RequestMethod.ALL });
  }
}
