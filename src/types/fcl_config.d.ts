// Config
export interface FlowConfig {
  put: (key: string, value: unknown) => FlowConfig;
  get: <T>(key: string, defaultValue: T) => T;
  update: <T>(key: string, updateFn: (oldValue: T) => T) => FlowConfig;
}
