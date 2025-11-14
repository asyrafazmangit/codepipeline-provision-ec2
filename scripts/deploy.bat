@echo off
setlocal enabledelayedexpansion

echo ========================================
echo     CodePipeline Deployment Script
echo ========================================

REM Set variables
set STACK_NAME=my-ec2-pipeline
set TEMPLATE_FILE=templates\codepipeline-template.yaml
set PARAMS_FILE=parameters\pipeline-params.json
set AWS_PROFILE=asyraf
set AWS_REGION=ap-southeast-1

echo Stack Name: %STACK_NAME%
echo Template: %TEMPLATE_FILE%
echo Parameters: %PARAMS_FILE%
echo AWS Profile: %AWS_PROFILE%
echo AWS Region: %AWS_REGION%
echo.

REM Check if parameters file exists
if not exist "%PARAMS_FILE%" (
    echo ERROR: Parameters file not found: %PARAMS_FILE%
    echo Please run setup.bat first
    pause
    exit /b 1
)

REM Check if template file exists
if not exist "%TEMPLATE_FILE%" (
    echo ERROR: Template file not found: %TEMPLATE_FILE%
    pause
    exit /b 1
)

echo Deploying CodePipeline stack...
echo This may take several minutes...
echo.

REM Deploy the stack
aws cloudformation deploy ^
  --template-file %TEMPLATE_FILE% ^
  --stack-name %STACK_NAME% ^
  --parameter-overrides file://%PARAMS_FILE% ^
  --capabilities CAPABILITY_IAM ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION%

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Stack deployment failed!
    echo Check the AWS CloudFormation console for details
    pause
    exit /b 1
)

echo.
echo ✓ Stack deployed successfully!
echo.

echo Getting stack outputs...
aws cloudformation describe-stacks ^
  --stack-name %STACK_NAME% ^
  --query "Stacks[0].Outputs" ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION% ^
  --output table

echo.
echo Deployment completed successfully!
echo.
echo Next steps:
echo 1. Create your GitHub repository
echo 2. Add ec2-template.yaml to the repository
echo 3. Push changes to trigger the pipeline
echo.
pause
