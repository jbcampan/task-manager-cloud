import { ForbiddenException, NotFoundException } from '@nestjs/common';
import type { TestingModule } from '@nestjs/testing';
import { Test } from '@nestjs/testing';

import { PrismaService } from '../prisma/prisma.service';

import { TasksService } from './tasks.service';

const mockPrismaService = {
  task: {
    create: jest.fn(),
    findMany: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
};

const mockTask = {
  id: 'task-id-1',
  title: 'Test Task',
  description: null,
  status: 'TODO',
  priority: 'MEDIUM',
  dueDate: null,
  userId: 'user-id-1',
  createdAt: new Date(),
  updatedAt: new Date(),
};

describe('TasksService', () => {
  let service: TasksService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TasksService, { provide: PrismaService, useValue: mockPrismaService }],
    }).compile();

    service = module.get<TasksService>(TasksService);
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('should create a task and return it', async () => {
      mockPrismaService.task.create.mockResolvedValue(mockTask);

      const result = await service.create('user-id-1', {
        title: 'Test Task',
      });

      expect(mockPrismaService.task.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          title: 'Test Task',
          userId: 'user-id-1',
        }),
      });
      expect(result).toEqual(mockTask);
    });
  });

  describe('findAll', () => {
    it('should return all tasks for a user', async () => {
      mockPrismaService.task.findMany.mockResolvedValue([mockTask]);

      const result = await service.findAll('user-id-1');

      expect(mockPrismaService.task.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ where: { userId: 'user-id-1' } }),
      );
      expect(result).toHaveLength(1);
    });

    it('should filter tasks by status when provided', async () => {
      mockPrismaService.task.findMany.mockResolvedValue([mockTask]);

      await service.findAll('user-id-1', 'TODO' as any);

      expect(mockPrismaService.task.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { userId: 'user-id-1', status: 'TODO' },
        }),
      );
    });
  });

  describe('findOne', () => {
    it('should return a task if it belongs to the user', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);

      const result = await service.findOne('user-id-1', 'task-id-1');

      expect(result).toEqual(mockTask);
    });

    it('should throw NotFoundException if task does not exist', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue(null);

      await expect(service.findOne('user-id-1', 'task-id-1')).rejects.toThrow(NotFoundException);
    });

    it('should throw ForbiddenException if task belongs to another user', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue({
        ...mockTask,
        userId: 'other-user-id',
      });

      await expect(service.findOne('user-id-1', 'task-id-1')).rejects.toThrow(ForbiddenException);
    });
  });

  describe('update', () => {
    it('should update and return the task', async () => {
      const updatedTask = { ...mockTask, title: 'Updated Task' };
      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.task.update.mockResolvedValue(updatedTask);

      const result = await service.update('user-id-1', 'task-id-1', {
        title: 'Updated Task',
      });

      expect(result.title).toBe('Updated Task');
    });
  });

  describe('remove', () => {
    it('should delete the task and return a success message', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.task.delete.mockResolvedValue(mockTask);

      const result = await service.remove('user-id-1', 'task-id-1');

      expect(mockPrismaService.task.delete).toHaveBeenCalledWith({
        where: { id: 'task-id-1' },
      });
      expect(result).toHaveProperty('message', 'Task deleted successfully');
    });
  });
});
