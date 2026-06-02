package com.gamestore.test;

import java.sql.Connection;
import java.sql.DriverManager;

public class DbTest {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=GameStore;encrypt=false";
        String user = "sa"; 
        String pass = "123456"; 

        try {
            System.out.println("Đang kết nối...");
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            Connection con = DriverManager.getConnection(url, user, pass);
            
            if (con != null) {
                System.out.println("KẾT NỐI THÀNH CÔNG!");
                con.close();
            }
        } catch (Exception e) {
            System.out.println("KẾT NỐI THẤT BẠI: " + e.getMessage());
            e.printStackTrace();
        }
    }
}