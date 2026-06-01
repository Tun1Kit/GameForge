#!/bin/bash
# ============================================================
# GameForge — Init Script (Unix/macOS/Linux)
# Chuẩn bị môi trường và xác minh baseline
# ============================================================

set -e

echo ""
echo "=== GameForge Init ==="
echo ""

# 1. Check Java
echo "[1/6] Checking Java..."
if command -v java &> /dev/null; then
    java -version 2>&1 | head -1
    echo "    OK: Java found"
else
    echo "    FAIL: Java not found. Please install JDK 8+."
    exit 1
fi

# 2. Check Maven
echo "[2/6] Checking Maven..."
if command -v mvn &> /dev/null; then
    mvn -version 2>&1 | head -1
    echo "    OK: Maven found"
else
    echo "    FAIL: Maven not found. Please install Maven 3.6+."
    exit 1
fi

# 3. Check SQL Server connection
echo "[3/6] Checking SQL Server..."
SQL_OK=0
if command -v sqlcmd &> /dev/null; then
    sqlcmd -S localhost\\SQLEXPRESS -U sa -P 123456 -Q "SELECT 1" -b &> /dev/null
    if [ $? -eq 0 ]; then
        echo "    OK: SQL Server connected"
        SQL_OK=1
    else
        echo "    WARN: Cannot connect to SQL Server."
        echo "    Make sure SQL Server (SQLEXPRESS) is running."
    fi
else
    echo "    WARN: sqlcmd not found (Windows SQL Server tools)."
    echo "    Install mssql-tools or run init.bat on Windows."
fi

# 4. Verify database exists
if [ "$SQL_OK" -eq 1 ]; then
    echo "[4/6] Verifying GameStore database..."
    DB_EXISTS=$(sqlcmd -S localhost\\SQLEXPRESS -U sa -P 123456 -d GameStore \
        -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = 'GameStore'" \
        -h -1 2>/dev/null | tr -d '[:space:]')
    if [ "$DB_EXISTS" -gt 0 ]; then
        echo "    OK: GameStore database exists"
    else
        echo "    FAIL: Database 'GameStore' not found. Run Store.sql first."
        exit 1
    fi
else
    echo "[4/6] Skipping database check (SQL not reachable)"
fi

# 5. Maven compile
echo "[5/6] Compiling project..."
cd "$(dirname "$0")"
mvn compile -q -DskipTests
if [ $? -eq 0 ]; then
    echo "    OK: Project compiles"
else
    echo "    FAIL: Maven compile failed. Run 'mvn compile' to see errors."
    exit 1
fi

# 6. Smoke test
echo "[6/6] Running smoke test..."
mvn test -Dtest=DbTest -q &> /dev/null
if [ $? -eq 0 ]; then
    echo "    OK: Smoke test passed"
else
    echo "    WARN: Smoke test failed. Check DbTest.java and database."
fi

echo ""
echo "=== Init Complete ==="
echo ""
echo "Next steps:"
echo "  1. mvn tomcat7:run    — Run locally"
echo "  2. mvn package        — Build WAR for Tomcat"
echo ""
