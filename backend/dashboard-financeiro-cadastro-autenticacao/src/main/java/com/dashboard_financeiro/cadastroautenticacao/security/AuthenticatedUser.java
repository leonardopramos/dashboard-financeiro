package com.dashboard_financeiro.cadastroautenticacao.security;

import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public record AuthenticatedUser(
        UUID id,
        String email,
        String name,
        String role,
        boolean active
) implements UserDetails {

    public static AuthenticatedUser from(UserJpaEntity entity) {
        return new AuthenticatedUser(
                entity.getId(),
                entity.getEmail(),
                entity.getName(),
                entity.getRole(),
                entity.isActive()
        );
    }

    public boolean hasRole(String expectedRole) {
        return role != null && role.equalsIgnoreCase(expectedRole);
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }

    @Override
    public String getPassword() {
        return "";
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return active;
    }

    @Override
    public boolean isAccountNonLocked() {
        return active;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return active;
    }

    @Override
    public boolean isEnabled() {
        return active;
    }
}
