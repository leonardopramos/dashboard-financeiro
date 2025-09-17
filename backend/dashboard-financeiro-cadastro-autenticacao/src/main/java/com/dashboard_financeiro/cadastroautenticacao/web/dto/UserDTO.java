package com.dashboard_financeiro.cadastroautenticacao.web.dto;


import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.UUID;

@Builder
public record UserDTO(
        UUID id,
        String cpf,
        String name,
        String email,
        String role,
        String street,
        Integer number,
        String neighborhood,
        String complement,
        String city,
        String state,
        String zipCode,
        boolean active,
        boolean emailVerified,
        LocalDateTime registeredAt
) {
    public static UserDTO from(UserJpaEntity userJpaEntity) {
        return UserDTO.builder()
                .id(userJpaEntity.getId())
                .cpf(userJpaEntity.getCpf())
                .name(userJpaEntity.getName())
                .email(userJpaEntity.getEmail())
                .role(userJpaEntity.getRole())
                .street(userJpaEntity.getStreet())
                .number(userJpaEntity.getNumber())
                .neighborhood(userJpaEntity.getNeighborhood())
                .complement(userJpaEntity.getComplement())
                .city(userJpaEntity.getCity())
                .state(userJpaEntity.getState())
                .zipCode(userJpaEntity.getZipCode())
                .active(userJpaEntity.isActive())
                .emailVerified(userJpaEntity.isEmailVerified())
                .registeredAt(userJpaEntity.getRegisteredAt())
                .build();
    }
}
