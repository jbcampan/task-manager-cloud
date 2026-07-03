import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { HealthCheck, HealthCheckService } from '@nestjs/terminus';

import { PrismaHealthIndicator } from './prisma.health';

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly prismaHealth: PrismaHealthIndicator,
  ) {}

  /**
   * Liveness probe - used by ECS/ALB to know if the process is alive.
   * Returns 200 as long as the Node.js process is running.
   * Does NOT check database connectivity (that would cause unnecessary
   * restarts during transient DB outages).
   */
  @Get('live')
  @ApiOperation({ summary: 'Liveness probe - process is running' })
  liveness() {
    return { status: 'ok' };
  }

  /**
   * Readiness probe - used by ECS/ALB to know if the app can serve traffic.
   * Checks database connectivity before marking the instance as ready.
   * ECS will stop routing traffic to an instance that fails this check.
   */
  @Get('ready')
  @HealthCheck()
  @ApiOperation({ summary: 'Readiness probe - app is ready to serve traffic' })
  readiness() {
    return this.health.check([() => this.prismaHealth.isHealthy('database')]);
  }
}
