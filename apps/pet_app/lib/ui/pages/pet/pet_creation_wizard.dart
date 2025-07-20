/*
---------------------------------------------------------------
File name:          pet_creation_wizard.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠创建向导 - 引导用户创建新的桌宠
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/pet_provider.dart';

/// 桌宠创建向导
class PetCreationWizard extends ConsumerStatefulWidget {
  const PetCreationWizard({super.key});

  @override
  ConsumerState<PetCreationWizard> createState() => _PetCreationWizardState();
}

class _PetCreationWizardState extends ConsumerState<PetCreationWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isCreating = false;

  // 桌宠属性
  String _name = '';
  String _type = 'cat';
  String _breed = 'domestic';
  String _color = 'orange';
  String _gender = 'unknown';

  final List<String> _petTypes = ['cat', 'dog', 'rabbit', 'bird', 'fish'];
  final Map<String, List<String>> _breeds = {
    'cat': ['domestic', 'persian', 'siamese', 'maine_coon', 'british_shorthair'],
    'dog': ['domestic', 'golden_retriever', 'labrador', 'poodle', 'bulldog'],
    'rabbit': ['domestic', 'holland_lop', 'netherland_dwarf', 'rex', 'angora'],
    'bird': ['domestic', 'canary', 'parakeet', 'cockatiel', 'lovebird'],
    'fish': ['domestic', 'goldfish', 'betta', 'guppy', 'angelfish'],
  };
  final List<String> _colors = ['orange', 'black', 'white', 'brown', 'gray', 'blue', 'pink'];
  final List<String> _genders = ['male', 'female', 'unknown'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '创建桌宠',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 进度指示器
          _buildProgressIndicator(),
          
          // 内容区域
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildNameStep(),
                _buildTypeStep(),
                _buildAppearanceStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          
          // 底部按钮
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < _currentStep ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pets,
            size: 80,
            color: Color(0xFF6C63FF),
          ),
          const SizedBox(height: 24),
          const Text(
            '给你的桌宠起个名字',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '这将是你的桌宠的专属名字',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            decoration: InputDecoration(
              labelText: '桌宠名字',
              hintText: '请输入桌宠名字',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6C63FF)),
              ),
              prefixIcon: const Icon(Icons.edit),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text(
            '选择桌宠类型',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '不同类型的桌宠有不同的特性',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _petTypes.length,
              itemBuilder: (context, index) {
                final type = _petTypes[index];
                final isSelected = _type == type;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _type = type;
                      _breed = _breeds[type]!.first;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getTypeIcon(type),
                          size: 48,
                          color: isSelected ? Colors.white : const Color(0xFF6C63FF),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getTypeDisplayName(type),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text(
            '自定义外观',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '选择桌宠的品种、颜色和性别',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildSelectionCard(
                  title: '品种',
                  options: _breeds[_type]!,
                  selectedValue: _breed,
                  onChanged: (value) {
                    setState(() {
                      _breed = value;
                    });
                  },
                  getDisplayName: _getBreedDisplayName,
                ),
                const SizedBox(height: 16),
                _buildSelectionCard(
                  title: '颜色',
                  options: _colors,
                  selectedValue: _color,
                  onChanged: (value) {
                    setState(() {
                      _color = value;
                    });
                  },
                  getDisplayName: _getColorDisplayName,
                ),
                const SizedBox(height: 16),
                _buildSelectionCard(
                  title: '性别',
                  options: _genders,
                  selectedValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  getDisplayName: _getGenderDisplayName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            '确认创建',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '请确认你的桌宠信息',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow('名字', _name),
                _buildInfoRow('类型', _getTypeDisplayName(_type)),
                _buildInfoRow('品种', _getBreedDisplayName(_breed)),
                _buildInfoRow('颜色', _getColorDisplayName(_color)),
                _buildInfoRow('性别', _getGenderDisplayName(_gender)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_isCreating)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            )
          else
            ElevatedButton(
              onPressed: _createPet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '创建桌宠',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onChanged,
    required String Function(String) getDisplayName,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedValue == option;
              return GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    getDisplayName(option),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('上一步'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_currentStep == 3 ? '完成' : '下一步'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _name.isNotEmpty;
      case 1:
        return _type.isNotEmpty;
      case 2:
        return _breed.isNotEmpty && _color.isNotEmpty && _gender.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createPet() async {
    setState(() {
      _isCreating = true;
    });

    try {
      await ref.read(petProvider.notifier).createPet(
        name: _name,
        type: _type,
        breed: _breed,
        color: _color,
        gender: _gender,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('桌宠 $_name 创建成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建桌宠失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'cat':
        return Icons.pets;
      case 'dog':
        return Icons.pets;
      case 'rabbit':
        return Icons.cruelty_free;
      case 'bird':
        return Icons.flutter_dash;
      case 'fish':
        return Icons.set_meal;
      default:
        return Icons.pets;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'cat':
        return '猫咪';
      case 'dog':
        return '狗狗';
      case 'rabbit':
        return '兔子';
      case 'bird':
        return '鸟儿';
      case 'fish':
        return '鱼儿';
      default:
        return type;
    }
  }

  String _getBreedDisplayName(String breed) {
    switch (breed) {
      case 'domestic':
        return '家养';
      case 'persian':
        return '波斯猫';
      case 'siamese':
        return '暹罗猫';
      case 'maine_coon':
        return '缅因猫';
      case 'british_shorthair':
        return '英短';
      case 'golden_retriever':
        return '金毛';
      case 'labrador':
        return '拉布拉多';
      case 'poodle':
        return '贵宾犬';
      case 'bulldog':
        return '斗牛犬';
      case 'holland_lop':
        return '荷兰垂耳兔';
      case 'netherland_dwarf':
        return '荷兰侏儒兔';
      case 'rex':
        return '雷克斯兔';
      case 'angora':
        return '安哥拉兔';
      case 'canary':
        return '金丝雀';
      case 'parakeet':
        return '鹦鹉';
      case 'cockatiel':
        return '玄凤鹦鹉';
      case 'lovebird':
        return '爱情鸟';
      case 'goldfish':
        return '金鱼';
      case 'betta':
        return '斗鱼';
      case 'guppy':
        return '孔雀鱼';
      case 'angelfish':
        return '神仙鱼';
      default:
        return breed;
    }
  }

  String _getColorDisplayName(String color) {
    switch (color) {
      case 'orange':
        return '橙色';
      case 'black':
        return '黑色';
      case 'white':
        return '白色';
      case 'brown':
        return '棕色';
      case 'gray':
        return '灰色';
      case 'blue':
        return '蓝色';
      case 'pink':
        return '粉色';
      default:
        return color;
    }
  }

  String _getGenderDisplayName(String gender) {
    switch (gender) {
      case 'male':
        return '雄性';
      case 'female':
        return '雌性';
      case 'unknown':
        return '未知';
      default:
        return gender;
    }
  }
}
