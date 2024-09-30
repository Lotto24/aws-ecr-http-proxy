# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2024-09-30
### Changed
- Explicit env source
- Crontab conf path changed

## [2.0.0] - 2024-08-24

### Added
- Support for AWS WebIdentity Token
- Support for AWS EC2 metadata
- Log of the AWS identity used
- Support to set custom renewal interval
- Fallback to AWS_REGION, AWS_DEFAULT_REGION and region in ECR URL

### Changed
- Upgraded to OpenResty 1.21.4.1
- Upgraded AWS CLI to 1.34.21
- Environment variables names simplified
- Cleaned up the repository structure
