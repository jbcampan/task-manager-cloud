import { Controller, Get, Res } from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import type { Response } from 'express';

import { MetricsService } from './metrics.service';

// Excluded from Swagger - this isn't part of the application's public API
// contract, it's a scrape target for Prometheus.
@ApiExcludeController()
@Controller('metrics')
export class MetricsController {
  constructor(private readonly metrics: MetricsService) {}

  @Get()
  async scrape(@Res() res: Response) {
    // @Res() hands full control of the response to this handler - the
    // global TransformResponseInterceptor (which wraps every other
    // response in the app's standard JSON envelope) never touches what's
    // written here. Required: the Prometheus text exposition format must
    // reach the scraper unmodified, not wrapped in application JSON.
    res.set('Content-Type', this.metrics.registry.contentType);
    res.end(await this.metrics.registry.metrics());
  }
}
