@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   CloudFormation Template Validation
echo ========================================

set AWS_PROFILE=asyraf
set AWS_REGION=ap-southeast-1

echo Validating CloudFormation templates...
echo.

REM Validate pipeline template
echo [1/2] Validating CodePipeline template...
aws cloudformation validate-template ^
  --template-body file://templates/codepipeline-template.yaml ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION%

if %errorlevel% neq 0 (
    echo ERROR: Pipeline template validation failed!
    pause
    exit /b 1
)

echo ✓ Pipeline template is valid
echo.

REM Validate EC2 template
echo [2/2] Validating EC2 template...
aws cloudformation validate-template ^
  --template-body file://ec2-template.yaml ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION%

if %errorlevel% neq 0 (
    echo ERROR: EC2 template validation failed!
    pause
    exit /b 1
)

echo ✓ EC2 template is valid
echo.
echo All templates validated successfully!
echo.
pause
