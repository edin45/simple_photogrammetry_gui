const gpuTypeEnvironmentVariable = 'SIMPLE_PHOTOGRAMMETRY_GPU_TYPE';

const _supportedGpuTypes = {'cpu', 'amd', 'cuda'};

String normalizeGpuType(String? value, {String fallback = 'cpu'}) {
  if (!_supportedGpuTypes.contains(fallback)) {
    throw ArgumentError.value(fallback, 'fallback', 'unsupported GPU type');
  }

  return _supportedGpuTypes.contains(value) ? value! : fallback;
}

String resolveGpuType(Map<String, String> environment) {
  return normalizeGpuType(environment[gpuTypeEnvironmentVariable]);
}
