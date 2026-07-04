import type { INestApplication } from '@nestjs/common';
import { VersioningType, ValidationPipe } from '@nestjs/common';
import type { TestingModule } from '@nestjs/testing';
import { Test } from '@nestjs/testing';
import request from 'supertest';

import { AppModule } from '../src/app.module';
import { HttpExceptionFilter } from '../src/common/filters/http-exception.filter';
import { TransformResponseInterceptor } from '../src/common/interceptors/transform-response.interceptor';

jest.setTimeout(30000);

describe('Task Manager API (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;

  const testUser = {
    email: `test-${Date.now()}@example.com`,
    password: 'TestP@ssw0rd',
    firstName: 'Test',
    lastName: 'User',
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();

    app.setGlobalPrefix('api');
    app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
        transformOptions: { enableImplicitConversion: true },
      }),
    );
    app.useGlobalFilters(new HttpExceptionFilter());
    app.useGlobalInterceptors(new TransformResponseInterceptor());

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  // ─── Health ───────────────────────────────────────────────────────────────

  describe('Health checks', () => {
    it('GET /api/v1/health/live → 200', () => {
      return request(app.getHttpServer()).get('/api/v1/health/live').expect(200);
    });

    it('GET /api/v1/health/ready → 200 (DB reachable)', () => {
      return request(app.getHttpServer()).get('/api/v1/health/ready').expect(200);
    });
  });

  // ─── Auth ─────────────────────────────────────────────────────────────────

  describe('Auth', () => {
    it('POST /api/v1/auth/register → 201 with accessToken', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/auth/register')
        .send(testUser)
        .expect(201);

      expect(res.body.data).toHaveProperty('accessToken');
      expect(res.body.data).toHaveProperty('tokenType', 'Bearer');
    });

    it('POST /api/v1/auth/register → 409 on duplicate email', () => {
      return request(app.getHttpServer()).post('/api/v1/auth/register').send(testUser).expect(409);
    });

    it('POST /api/v1/auth/login → 200 with accessToken', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ email: testUser.email, password: testUser.password })
        .expect(200);

      expect(res.body.data).toHaveProperty('accessToken');
      accessToken = res.body.data.accessToken;
    });

    it('POST /api/v1/auth/login → 401 on wrong password', () => {
      return request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ email: testUser.email, password: 'wrongpassword' })
        .expect(401);
    });
  });

  // ─── Tasks ────────────────────────────────────────────────────────────────

  describe('Tasks', () => {
    let taskId: string;

    it('GET /api/v1/tasks → 401 without token', () => {
      return request(app.getHttpServer()).get('/api/v1/tasks').expect(401);
    });

    it('POST /api/v1/tasks → 201 creates a task', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/tasks')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ title: 'E2E Test Task', priority: 'HIGH' })
        .expect(201);

      expect(res.body.data).toHaveProperty('id');
      expect(res.body.data.title).toBe('E2E Test Task');
      taskId = res.body.data.id;
    });

    it('GET /api/v1/tasks → 200 returns array', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/tasks')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('PATCH /api/v1/tasks/:id → 200 updates status', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/v1/tasks/${taskId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ status: 'IN_PROGRESS' })
        .expect(200);

      expect(res.body.data.status).toBe('IN_PROGRESS');
    });

    it('DELETE /api/v1/tasks/:id → 200 deletes task', () => {
      return request(app.getHttpServer())
        .delete(`/api/v1/tasks/${taskId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);
    });
  });
});
