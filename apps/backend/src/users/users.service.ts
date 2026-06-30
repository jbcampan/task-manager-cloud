import { Injectable } from '@nestjs/common';

import type { AuthenticatedUser } from '../common/decorators/current-user.decorator';
import { PrismaService } from '../prisma/prisma.service';

interface CreateUserInput {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: CreateUserInput) {
    return this.prisma.user.create({ data });
  }

  async findById(id: string): Promise<AuthenticatedUser | null> {
    return this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email } });
  }
}
