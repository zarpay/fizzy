import { Construct } from 'constructs';
import * as cdk from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as iam from 'aws-cdk-lib/aws-iam';
import { isProduction, region } from '../shared/global-variables';

export class Storage extends Construct {
  public readonly bucket: s3.Bucket;

  constructor(scope: Construct, id: string) {
    super(scope, id);

    this.bucket = new s3.Bucket(this, 'ActiveStorageBucket', {
      encryption: s3.BucketEncryption.S3_MANAGED,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      enforceSSL: true,
      versioned: false,
      removalPolicy: isProduction ? cdk.RemovalPolicy.RETAIN : cdk.RemovalPolicy.DESTROY,
      autoDeleteObjects: !isProduction,
      cors: [
        {
          allowedMethods: [s3.HttpMethods.GET, s3.HttpMethods.PUT, s3.HttpMethods.POST],
          allowedOrigins: ['*'],
          allowedHeaders: ['*'],
          exposedHeaders: ['ETag'],
          maxAge: 3600,
        },
      ],
    });
  }

  /**
   * Grant read/write permissions to an IAM role
   */
  grantReadWrite(grantee: iam.IGrantable): iam.Grant {
    return this.bucket.grantReadWrite(grantee);
  }

  /**
   * Environment variables for Rails ActiveStorage S3 config
   */
  get environmentVariables(): Record<string, string> {
    const s3Url = `https://${this.bucket.bucketName}.s3.${region}.amazonaws.com`;
    return {
      ACTIVE_STORAGE_SERVICE: 's3',
      S3_BUCKET: this.bucket.bucketName,
      S3_REGION: region,
      // CSP: Allow browser to connect to S3 for direct uploads
      CSP_CONNECT_SRC: s3Url,
      CSP_IMG_SRC: s3Url,
    };
  }
}
