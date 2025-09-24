return {
  -- LuaSnip for CDK snippets
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node

    -- CDK-specific snippets
    ls.add_snippets("typescript", {
      -- Basic CDK Stack
      s("cdkstack", {
        t("import * as cdk from 'aws-cdk-lib';"),
        t({"", "import { Construct } from 'constructs';", "", ""}),
        t("export class "), i(1, "MyStack"), t(" extends cdk.Stack {"),
        t({"", "  constructor(scope: Construct, id: string, props?: cdk.StackProps) {", ""}),
        t("    super(scope, id, props);"),
        t({"", "", "    // "}), i(2, "Add your resources here"),
        t({"", "  }", "}"}),
      }),

      -- CDK App
      s("cdkapp", {
        t("#!/usr/bin/env node"),
        t({"", "import 'source-map-support/register';", ""}),
        t("import * as cdk from 'aws-cdk-lib';"),
        t({"", "import { "}), i(1, "MyStack"), t(" } from './"), i(2, "my-stack"), t("';"),
        t({"", "", "const app = new cdk.App();", ""}),
        t("new "), f(function(args) return args[1][1] end, {1}), t("(app, '"), i(3, "MyStack"), t("', {"),
        t({"", "  // "}), i(4, "Add stack props here"),
        t({"", "});"}),
      }),

      -- Lambda Function
      s("cdklambda", {
        t("import * as lambda from 'aws-cdk-lib/aws-lambda';"),
        t({"", "", "const "}), i(1, "myFunction"), t(" = new lambda.Function(this, '"), i(2, "MyFunction"), t("', {"),
        t({"", "  runtime: lambda.Runtime."}), i(3, "NODEJS_18_X"), t(","),
        t({"", "  handler: '"}), i(4, "index.handler"), t("',"),
        t({"", "  code: lambda.Code.fromAsset('"}), i(5, "lambda"), t("'),"),
        t({"", "});"}),
      }),

      -- API Gateway
      s("cdkapi", {
        t("import * as apigateway from 'aws-cdk-lib/aws-apigateway';"),
        t({"", "", "const "}), i(1, "api"), t(" = new apigateway.RestApi(this, '"), i(2, "MyApi"), t("', {"),
        t({"", "  restApiName: '"}), i(3, "My Service"), t("',"),
        t({"", "  description: '"}), i(4, "This service serves..."), t("',"),
        t({"", "});"}),
      }),

      -- DynamoDB Table
      s("cdkdynamo", {
        t("import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';"),
        t({"", "", "const "}), i(1, "table"), t(" = new dynamodb.Table(this, '"), i(2, "MyTable"), t("', {"),
        t({"", "  partitionKey: { name: '"}), i(3, "id"), t("', type: dynamodb.AttributeType.STRING },"),
        t({"", "  billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,"}),
        t({"", "  removalPolicy: cdk.RemovalPolicy.DESTROY, // ⚠️  Only for dev/test"}),
        t({"", "});"}),
      }),

      -- S3 Bucket
      s("cdks3", {
        t("import * as s3 from 'aws-cdk-lib/aws-s3';"),
        t({"", "", "const "}), i(1, "bucket"), t(" = new s3.Bucket(this, '"), i(2, "MyBucket"), t("', {"),
        t({"", "  versioned: "}), i(3, "true"), t(","),
        t({"", "  removalPolicy: cdk.RemovalPolicy.DESTROY, // ⚠️  Only for dev/test"}),
        t({"", "  autoDeleteObjects: true, // ⚠️  Only for dev/test"}),
        t({"", "});"}),
      }),

      -- VPC
      s("cdkvpc", {
        t("import * as ec2 from 'aws-cdk-lib/aws-ec2';"),
        t({"", "", "const "}), i(1, "vpc"), t(" = new ec2.Vpc(this, '"), i(2, "MyVpc"), t("', {"),
        t({"", "  maxAzs: "}), i(3, "2"), t(","),
        t({"", "  cidr: '"}), i(4, "10.0.0.0/16"), t("',"),
        t({"", "});"}),
      }),

      -- CDK Import
      s("cdkimport", {
        t("import * as "), i(1, "service"), t(" from 'aws-cdk-lib/aws-"), f(function(args) return args[1][1] end, {1}), t("';"),
      }),

      -- CDK Output
      s("cdkoutput", {
        t("new cdk.CfnOutput(this, '"), i(1, "OutputName"), t("', {"),
        t({"", "  value: "}), i(2, "value"), t(","),
        t({"", "  description: '"}), i(3, "Description"), t("',"),
        t({"", "});"}),
      }),
    })

    -- JavaScript versions of the same snippets
    ls.add_snippets("javascript", {
      s("cdkstack", {
        t("const cdk = require('aws-cdk-lib');"),
        t({"", "const { Construct } = require('constructs');", "", ""}),
        t("class "), i(1, "MyStack"), t(" extends cdk.Stack {"),
        t({"", "  constructor(scope, id, props) {", ""}),
        t("    super(scope, id, props);"),
        t({"", "", "    // "}), i(2, "Add your resources here"),
        t({"", "  }", "}", "", "module.exports = { "}), f(function(args) return args[1][1] end, {1}), t(" };"),
      }),
    })

    -- Load friendly snippets
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
