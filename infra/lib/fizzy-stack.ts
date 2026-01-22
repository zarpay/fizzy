import * as cdk from 'aws-cdk-lib/core';
import { awsOrganizationAccounts, EcrRepository, Platform } from '@zarpay/zar-cdk-lib';
import { Construct } from 'constructs';
import { Database } from './constructs/database.js';
import { Service } from './constructs/service.js';
import { Storage } from './constructs/storage.js';
import { isProduction, vpcName } from './shared/global-variables.js';

export class FizzyStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: cdk.StackProps) {
    super(scope, id, props);

    // Acknowledge warnings for imported managed policies
    cdk.Annotations.of(this).acknowledgeWarning('@aws-cdk/core:addConstructMetadataFailed');

    const vpc = Platform.vpcFromLookup(this, 'ImportedVpc', vpcName);

    const database = new Database(this, 'Database', { vpc });
    const storage = new Storage(this, 'Storage');

    const service = new Service(this, 'Service', { vpc, database, storage });
    service.node.addDependency(database);

    // ECR repository only in Production - other environments pull from here
    if (isProduction) {
      new EcrRepository(this, 'EcrRepository', {
        repositoryName: 'fizzy',
        trustedAwsAccounts: [awsOrganizationAccounts['DevOps Playground'], awsOrganizationAccounts['Staging']],
      });
    }
  }
}
