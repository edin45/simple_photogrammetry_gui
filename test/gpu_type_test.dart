import 'package:flutter_test/flutter_test.dart';
import 'package:simple_photogrammetry_gui/utils/gpu_type.dart';

void main() {
  group('resolveGpuType', () {
    test('uses the CPU fallback when the environment value is absent', () {
      expect(resolveGpuType(const {}), 'cpu');
    });

    for (final gpuType in ['cpu', 'amd', 'cuda']) {
      test('accepts $gpuType', () {
        expect(
          resolveGpuType({'SIMPLE_PHOTOGRAMMETRY_GPU_TYPE': gpuType}),
          gpuType,
        );
      });
    }

    test('uses the CPU fallback for an unknown value', () {
      expect(
        resolveGpuType(const {'SIMPLE_PHOTOGRAMMETRY_GPU_TYPE': 'metal'}),
        'cpu',
      );
    });

    test('supports the Windows missing-preference fallback', () {
      expect(normalizeGpuType(null, fallback: 'cuda'), 'cuda');
    });
  });
}
