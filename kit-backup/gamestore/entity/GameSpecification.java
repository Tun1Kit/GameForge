package com.gamestore.entity;

import javax.persistence.*;

@Entity
@Table(name = "game_specifications")
public class GameSpecification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "spec_type")
    private String specType; // MINIMUM hoặc RECOMMENDED

    private String os;
    private String cpu;
    private String ram;
    private String gpu;
    private String storage;

    // Getters and Setters
}