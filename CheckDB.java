import java.sql.*;
public class CheckDB {
    public static void main(String[] args) throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection conn = DriverManager.getConnection("jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=GameStore;encrypt=false;trustServerCertificate=true", "sa", "123456");
        ResultSet rs = conn.createStatement().executeQuery("SELECT TOP 1 * FROM orders");
        ResultSetMetaData meta = rs.getMetaData();
        for(int i=1; i<=meta.getColumnCount(); i++) {
            System.out.println(meta.getColumnName(i));
        }
        conn.close();
    }
}
