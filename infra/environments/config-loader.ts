import * as fs from 'fs';
import * as path from 'path';
import { environment } from '../lib/shared/global-variables';

function deepMerge(target: any, source: any): any {
  if (typeof target !== 'object' || typeof source !== 'object') {
    return source;
  }

  const result = { ...target };

  for (const key of Object.keys(source)) {
    if (source[key] !== null && typeof source[key] === 'object' && !Array.isArray(source[key])) {
      result[key] = deepMerge(target[key] ?? {}, source[key]);
    } else {
      result[key] = source[key];
    }
  }

  return result;
}

const defaultPath = path.join(__dirname, 'default.json');
const envPath = path.join(__dirname, `${environment}.json`);

const defaultConfig = JSON.parse(fs.readFileSync(defaultPath, 'utf-8'));
const envConfig = fs.existsSync(envPath) ? JSON.parse(fs.readFileSync(envPath, 'utf-8')) : {};

const mergedConfig = deepMerge(defaultConfig, envConfig);

export const config = Object.freeze(mergedConfig);
