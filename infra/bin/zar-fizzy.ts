#!/usr/bin/env node
import 'source-map-support/register';

import { ZarApp } from '@zarpay/zar-cdk-lib';
import { FizzyStack } from '../lib/fizzy-stack.js';
import { environment, region } from '../lib/shared/global-variables.js';

const app = new ZarApp({
  deployEnvironment: environment,
});

const env = app.environment(region);

new FizzyStack(app, `Fizzy-${environment}`, { env });
