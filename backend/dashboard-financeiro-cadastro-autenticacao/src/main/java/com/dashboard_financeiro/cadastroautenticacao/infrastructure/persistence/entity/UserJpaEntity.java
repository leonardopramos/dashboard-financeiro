package com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserJpaEntity {

    @Id
    private UUID id;

    private String cpf;
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    private String password;

    @Builder.Default
    private String role = "USER";

    private String street;
    private Integer number;
    private String neighborhood;
    private String complement;
    private String city;
    private String state;
    private String zipCode;

    @Builder.Default
    private boolean emailVerified = false;

    @Builder.Default
    private boolean active = true;

    private LocalDateTime registeredAt;
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        id = UUID.randomUUID();
        registeredAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
