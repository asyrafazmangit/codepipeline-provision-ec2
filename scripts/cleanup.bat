@echo off
setlocal enabledelayedexpansion

echo ========================================
echo       Resource Cleanup Script
echo ========================================

set STACK_NAME=my-ec2-pipeline
set EC2_STACK_NAME=%STACK_NAME%-ec2
set AWS_PROFILE=asyraf
set AWS_REGION=ap-southeast-1

echo This will delete the following stacks:
echo - %STACK_NAME% (CodePipeline)
echo - %EC2_STACK_NAME% (EC2 Instance)
echo.

set /p CONFIRM="Are you sure you want to delete these resources? (y/N): "

if /i not "%CONFIRM%"=="y" (
    echo Operation cancelled
    pause
    exit /b 0
)

echo.
echo Deleting EC2 stack first...
aws cloudformation delete-stack ^
  --stack-name %EC2_STACK_NAME% ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION%

if %errorlevel% neq 0 (
    echo Warning: EC2 stack deletion failed or stack doesn't exist
)

echo Waiting for EC2 stack deletion to complete...
aws cloudformation wait stack-delete-complete ^
  --stack-name %EC2_STACK_NAME% ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION%

echo.
echo Deleting CodePipeline stack...
aws cloudformation delete-stack ^
  --stack-name %STACK_NAME% ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION%

if %errorlevel% neq 0 (
    echo ERROR: Pipeline stack deletion failed
    pause
    exit /b 1
)

echo Waiting for pipeline stack deletion to complete...
aws cloudformation wait stack-delete-complete ^
  --stack-name %STACK_NAME% ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION%

echo.
echo ✓ All resources have been deleted successfully!
echo.
pause
