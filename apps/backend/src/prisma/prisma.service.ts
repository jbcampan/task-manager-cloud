import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
  }

  // Graceful shutdown: Prisma closes its connection pool on SIGTERM
  // NestJS calls this automatically via enableShutdownHooks()
}
