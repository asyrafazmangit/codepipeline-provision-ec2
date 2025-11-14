@echo off
setlocal enabledelayedexpansion

echo ========================================
echo        Stack Status Check
echo ========================================

set STACK_NAME=my-ec2-pipeline
set EC2_STACK_NAME=%STACK_NAME%-ec2
set AWS_PROFILE=asyraf
set AWS_REGION=ap-southeast-1

echo Checking CodePipeline stack status...
aws cloudformation describe-stacks ^
  --stack-name %STACK_NAME% ^
  --query "Stacks[0].[StackName,StackStatus]" ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION% ^
  --output table 2>nul

if %errorlevel% neq 0 (
    echo CodePipeline stack not found or error occurred
)

echo.
echo Checking EC2 stack status...
aws cloudformation describe-stacks ^
  --stack-name %EC2_STACK_NAME% ^
  --query "Stacks[0].[StackName,StackStatus]" ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION% ^
  --output table 2>nul

if %errorlevel% neq 0 (
    echo EC2 stack not found or error occurred
)

echo.
echo Checking pipeline execution status...
aws codepipeline list-pipeline-executions ^
  --pipeline-name %STACK_NAME%-pipeline ^
  --max-items 5 ^
  --profile %AWS_PROFILE% ^
  --region %AWS_REGION% ^
  --query "pipelineExecutionSummaries[*].[pipelineExecutionId,status,startTime]" ^
  --output table 2>nul

if %errorlevel% neq 0 (
    echo Pipeline not found or no executions
)

echo.
pause
