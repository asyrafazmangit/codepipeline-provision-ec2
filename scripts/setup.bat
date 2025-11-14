@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    AWS CodePipeline Setup Script
echo ========================================

REM Set AWS Profile and Region
set AWS_PROFILE=asyraf
set AWS_REGION=ap-southeast-1

echo Setting AWS Profile: %AWS_PROFILE%
echo Setting AWS Region: %AWS_REGION%

REM Check if AWS CLI is installed
aws --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: AWS CLI is not installed or not in PATH
    echo Please install AWS CLI first
    pause
    exit /b 1
)

echo AWS CLI is available

REM Check AWS credentials
echo Checking AWS credentials...
aws sts get-caller-identity --profile %AWS_PROFILE% --region %AWS_REGION% >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: AWS credentials not configured properly
    echo Please run: aws configure --profile %AWS_PROFILE%
    pause
    exit /b 1
)

echo AWS credentials are valid

REM Get VPC information
echo.
echo Getting your VPC information...
echo Available VPCs:
aws ec2 describe-vpcs --profile %AWS_PROFILE% --region %AWS_REGION% --query "Vpcs[*].[VpcId,Tags[?Key=='Name'].Value|[0],CidrBlock]" --output table

echo.
echo Getting subnet information...
set /p VPC_ID="Enter your VPC ID: "

if "%VPC_ID%"=="" (
    echo ERROR: VPC ID cannot be empty
    pause
    exit /b 1
)

echo.
echo Available subnets in VPC %VPC_ID%:
aws ec2 describe-subnets --filters "Name=vpc-id,Values=%VPC_ID%" --profile %AWS_PROFILE% --region %AWS_REGION% --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key=='Name'].Value|[0]]" --output table

echo.
set /p SUBNET_ID="Enter your Subnet ID: "

if "%SUBNET_ID%"=="" (
    echo ERROR: Subnet ID cannot be empty
    pause
    exit /b 1
)

REM Get Key Pair information
echo.
echo Available Key Pairs:
aws ec2 describe-key-pairs --profile %AWS_PROFILE% --region %AWS_REGION% --query "KeyPairs[*].KeyName" --output table

echo.
set /p KEY_PAIR="Enter your Key Pair name: "

if "%KEY_PAIR%"=="" (
    echo ERROR: Key Pair name cannot be empty
    pause
    exit /b 1
)

REM Get GitHub information
echo.
set /p GITHUB_OWNER="Enter your GitHub username: "
set /p GITHUB_REPO="Enter your GitHub repository name: "
set /p GITHUB_TOKEN="Enter your GitHub personal access token: "

REM Create parameters file
echo Creating parameters file...
(
echo [
echo   {
echo     "ParameterKey": "GitHubOwner",
echo     "ParameterValue": "%GITHUB_OWNER%"
echo   },
echo   {
echo     "ParameterKey": "GitHubRepo",
echo     "ParameterValue": "%GITHUB_REPO%"
echo   },
echo   {
echo     "ParameterKey": "GitHubToken",
echo     "ParameterValue": "%GITHUB_TOKEN%"
echo   },
echo   {
echo     "ParameterKey": "VPCId",
echo     "ParameterValue": "%VPC_ID%"
echo   },
echo   {
echo     "ParameterKey": "SubnetId",
echo     "ParameterValue": "%SUBNET_ID%"
echo   },
echo   {
echo     "ParameterKey": "KeyPairName",
echo     "ParameterValue": "%KEY_PAIR%"
echo   }
echo ]
) > parameters\pipeline-params.json

echo.
echo Setup completed successfully!
echo Parameters saved to: parameters\pipeline-params.json
echo.
echo Next steps:
echo 1. Run: scripts\validate.bat
echo 2. Run: scripts\deploy.bat
echo.
pause
