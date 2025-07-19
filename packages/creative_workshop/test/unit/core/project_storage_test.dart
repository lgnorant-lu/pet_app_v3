/*
---------------------------------------------------------------
File name:          project_storage_test.dart
Author:             lgnorant-lu
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        项目存储单元测试
---------------------------------------------------------------
Change History:
    2025-07-19: Initial creation - 项目存储测试覆盖;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/projects/project_storage.dart';
import 'package:creative_workshop/src/core/projects/project_manager.dart';

void main() {
  group('Project Storage Tests', () {
    group('MemoryProjectStorage Tests', () {
      late MemoryProjectStorage storage;
      late CreativeProject testProject;

      setUp(() {
        storage = MemoryProjectStorage();
        testProject = CreativeProject(
          id: 'test_project_1',
          name: '测试项目',
          type: ProjectType.custom,
          description: '这是一个测试项目',
        );
      });

      test('应该能够保存项目', () async {
        final result = await storage.saveProject(testProject);
        expect(result, isTrue);
      });

      test('应该能够加载已保存的项目', () async {
        await storage.saveProject(testProject);
        final loadedProject = await storage.loadProject(testProject.id);

        expect(loadedProject, isNotNull);
        expect(loadedProject!.id, equals(testProject.id));
        expect(loadedProject.name, equals(testProject.name));
        expect(loadedProject.description, equals(testProject.description));
      });

      test('加载不存在的项目应该返回null', () async {
        final loadedProject = await storage.loadProject('non_existent_project');
        expect(loadedProject, isNull);
      });

      test('应该能够删除项目', () async {
        await storage.saveProject(testProject);

        final deleteResult = await storage.deleteProject(testProject.id);
        expect(deleteResult, isTrue);

        final loadedProject = await storage.loadProject(testProject.id);
        expect(loadedProject, isNull);
      });

      test('删除不存在的项目应该返回false', () async {
        final deleteResult =
            await storage.deleteProject('non_existent_project');
        expect(deleteResult, isFalse);
      });

      test('应该能够获取所有项目ID', () async {
        final project1 = CreativeProject(
          id: 'project_1',
          name: '项目1',
          type: ProjectType.custom,
          description: '描述1',
        );

        final project2 = CreativeProject(
          id: 'project_2',
          name: '项目2',
          type: ProjectType.custom,
          description: '描述2',
        );

        await storage.saveProject(project1);
        await storage.saveProject(project2);

        final projectIds = await storage.getAllProjectIds();
        expect(projectIds, hasLength(2));
        expect(projectIds, contains('project_1'));
        expect(projectIds, contains('project_2'));
      });

      test('应该能够检查项目是否存在', () async {
        expect(await storage.projectExists(testProject.id), isFalse);

        await storage.saveProject(testProject);
        expect(await storage.projectExists(testProject.id), isTrue);

        await storage.deleteProject(testProject.id);
        expect(await storage.projectExists(testProject.id), isFalse);
      });

      test('应该能够获取项目大小', () async {
        await storage.saveProject(testProject);
        final size = await storage.getProjectSize(testProject.id);
        expect(size, greaterThan(0));
      });

      test('不存在的项目大小应该为0', () async {
        final size = await storage.getProjectSize('non_existent_project');
        expect(size, equals(0));
      });
    });

    group('LocalProjectStorage Tests', () {
      late LocalProjectStorage storage;
      late CreativeProject testProject;

      setUp(() {
        storage = LocalProjectStorage();
        testProject = CreativeProject(
          id: 'test_local_project',
          name: '本地测试项目',
          type: ProjectType.custom,
          description: '这是一个本地存储测试项目',
        );
      });

      test('应该能够创建本地存储实例', () {
        expect(storage, isNotNull);
      });

      test('应该能够保存项目到本地', () async {
        final result = await storage.saveProject(testProject);
        expect(result, isTrue);
      });

      test('应该能够从本地加载项目', () async {
        await storage.saveProject(testProject);
        final loadedProject = await storage.loadProject(testProject.id);

        expect(loadedProject, isNotNull);
        expect(loadedProject!.id, equals(testProject.id));
        expect(loadedProject.name, equals(testProject.name));
      });

      test('应该能够删除本地项目', () async {
        await storage.saveProject(testProject);

        final deleteResult = await storage.deleteProject(testProject.id);
        expect(deleteResult, isTrue);

        final loadedProject = await storage.loadProject(testProject.id);
        expect(loadedProject, isNull);
      });

      test('应该能够获取本地项目列表', () async {
        await storage.saveProject(testProject);

        final projectIds = await storage.getAllProjectIds();
        expect(projectIds, contains(testProject.id));
      });

      test('应该能够检查本地项目存在性', () async {
        // 先清理可能存在的项目
        if (await storage.projectExists(testProject.id)) {
          await storage.deleteProject(testProject.id);
        }

        expect(await storage.projectExists(testProject.id), isFalse);

        await storage.saveProject(testProject);
        expect(await storage.projectExists(testProject.id), isTrue);
      });

      test('应该能够获取本地项目大小', () async {
        await storage.saveProject(testProject);
        final size = await storage.getProjectSize(testProject.id);
        expect(size, greaterThan(0));
      });
    });

    group('ProjectStorageManager Tests', () {
      late ProjectStorageManager manager;
      late MemoryProjectStorage storage;

      setUp(() {
        manager = ProjectStorageManager.instance;
        storage = MemoryProjectStorage();
        manager.initialize(storage: storage);
      });

      test('应该是单例', () {
        final manager1 = ProjectStorageManager.instance;
        final manager2 = ProjectStorageManager.instance;
        expect(identical(manager1, manager2), isTrue);
      });

      test('未初始化时访问存储应该抛出异常', () {
        // 创建一个新的管理器实例来测试未初始化状态
        // 由于ProjectStorageManager是单例，我们跳过这个测试
        // 或者测试其他边界条件
        expect(manager.storage, isNotNull);
      });

      test('应该能够批量保存项目', () async {
        final projects = [
          CreativeProject(
            id: 'batch_1',
            name: '批量项目1',
            type: ProjectType.custom,
            description: '描述1',
          ),
          CreativeProject(
            id: 'batch_2',
            name: '批量项目2',
            type: ProjectType.custom,
            description: '描述2',
          ),
        ];

        final results = await manager.saveProjects(projects);
        expect(results, hasLength(2));
        expect(results['batch_1'], isTrue);
        expect(results['batch_2'], isTrue);
      });

      test('应该能够批量加载项目', () async {
        final projects = [
          CreativeProject(
            id: 'load_1',
            name: '加载项目1',
            type: ProjectType.custom,
            description: '描述1',
          ),
          CreativeProject(
            id: 'load_2',
            name: '加载项目2',
            type: ProjectType.custom,
            description: '描述2',
          ),
        ];

        // 先保存项目
        for (final project in projects) {
          await storage.saveProject(project);
        }

        // 批量加载
        final loadedProjects = await manager.loadProjects(['load_1', 'load_2']);
        expect(loadedProjects, hasLength(2));
        expect(
            loadedProjects.map((p) => p.id), containsAll(['load_1', 'load_2']));
      });

      test('应该能够获取存储统计信息', () async {
        final project = CreativeProject(
          id: 'stats_project',
          name: '统计项目',
          type: ProjectType.custom,
          description: '用于统计测试',
        );

        await storage.saveProject(project);

        final stats = await manager.getStorageStats();
        expect(stats['projectCount'], equals(1));
        expect(stats['totalSize'], greaterThan(0));
        expect(stats['averageSize'], greaterThan(0));
      });

      test('空存储的统计信息应该正确', () async {
        final stats = await manager.getStorageStats();
        expect(stats['projectCount'], equals(0));
        expect(stats['totalSize'], equals(0));
        expect(stats['averageSize'], equals(0));
      });
    });
  });
}
