@echo off
REM ============================================================
REM GameForge — Init Script
REM Chuẩn bị môi trường và xác minh baseline trước khi làm việc
REM ============================================================

echo.
echo === GameForge Init ===
echo.

REM 1. Check Java
echo [1/6] Checking Java...
java -version 2>&1 | findstr /C:"version" >nul
if errorlevel 1 (
    echo    FAIL: Java not found. Please install JDK 8+.
    goto :fail
) else (
    echo    OK: Java found
)

REM 2. Check Maven
echo [2/6] Checking Maven...
mvn -version 2>&1 | findstr /C:"Maven" >nul
if errorlevel 1 (
    echo    FAIL: Maven not found. Please install Maven 3.6+.
    goto :fail
) else (
    echo    OK: Maven found
)

REM 3. Check SQL Server connection
echo [3/6] Checking SQL Server...
sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -Q "SELECT 1" -b >nul 2>&1
if errorlevel 1 (
    echo    WARN: Cannot connect to SQL Server.
    echo    Make sure SQL Server (SQLEXPRESS) is running.
    echo    And database 'GameStore' exists (run Store.sql).
    set SQL_OK=0
) else (
    echo    OK: SQL Server connected
    set SQL_OK=1
)

REM 4. Verify database exists
if "%SQL_OK%"=="1" (
    echo [4/6] Verifying GameStore database...
    sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -Q "SELECT name FROM sys.databases WHERE name = 'GameStore'" -h -1 | findstr /C:"GameStore" >nul 2>&1
    if errorlevel 1 (
        echo    FAIL: Database 'GameStore' not found. Run Store.sql first.
        goto :fail
    ) else (
        echo    OK: GameStore database exists
    )
) else (
    echo [4/6] Skipping database check (SQL not reachable)
)

REM 5. Maven compile (verify code compiles)
echo [5/6] Compiling project...
cd /d "%~dp0"
call mvn compile -q -DskipTests >nul 2>&1
if errorlevel 1 (
    echo    FAIL: Maven compile failed.
    echo    Run 'mvn compile' to see detailed errors.
    goto :fail
) else (
    echo    OK: Project compiles
)

REM 6. Smoke test (optional — if smoke test class exists)
echo [6/6] Running smoke test...
call mvn test -Dtest=DbTest -q >nul 2>&1
if errorlevel 1 (
    echo    WARN: Smoke test failed. Check DbTest.java and database connection.
) else (
    echo    OK: Smoke test passed
)

echo.
echo === Init Complete ===
echo.
echo Next steps:
echo   1. mvn tomcat7:run    — Run locally
echo   2. mvn package        — Build WAR for Tomcat
echo.
goto :end

:fail
echo.
echo === Init FAILED ===
echo.
echo Fix the issues above before continuing.
echo.
exit /b 1

:end
exit /b 0
