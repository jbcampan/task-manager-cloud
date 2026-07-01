import { ConflictException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';

import { UsersService } from '../users/users.service';

import type { RegisterDto } from './dto/register.dto';
import type { JwtPayload } from './strategies/jwt.strategy';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.usersService.findByEmail(dto.email);
    if (existing) {
      throw new ConflictException('Email already in use');
    }

    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(dto.password, saltRounds);

    const user = await this.usersService.create({
      ...dto,
      password: hashedPassword,
    });

    return this.generateTokenResponse(user.id, user.email);
  }

  async validateUser(email: string, password: string) {
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      return null;
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return null;
    }

    const { password: _password, ...result } = user;
    return result;
  }

  async login(userId: string, email: string) {
    return this.generateTokenResponse(userId, email);
  }

  private generateTokenResponse(userId: string, email: string) {
    const payload: JwtPayload = { sub: userId, email };
    const accessToken = this.jwtService.sign(payload);
    const expiresIn = this.config.get<string>('JWT_EXPIRES_IN', '7d');

    return {
      accessToken,
      expiresIn,
      tokenType: 'Bearer',
    };
  }
}
