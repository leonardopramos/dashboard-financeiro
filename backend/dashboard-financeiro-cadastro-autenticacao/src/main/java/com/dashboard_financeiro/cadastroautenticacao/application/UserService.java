package com.dashboard_financeiro.cadastroautenticacao.application;

import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.entity.UserJpaEntity;
import com.dashboard_financeiro.cadastroautenticacao.infrastructure.persistence.repository.UserJpaRepository;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.CreateUserRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UserDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserJpaRepository repo;
    private final PasswordEncoder encoder;

    public UserDTO register(CreateUserRequest req) {
        repo.findByEmail(req.email())
                .ifPresent(u -> { throw new IllegalArgumentException("Email já cadastrado"); });

        var entity = UserJpaEntity.builder()
                .id(UUID.randomUUID())
                .cpf(req.cpf())
                .name(req.name())
                .email(req.email())
                .password(encoder.encode(req.password()))
                .role(req.role() != null ? req.role() : "USER")
                .street(req.street())
                .number(req.number())
                .neighborhood(req.neighborhood())
                .complement(req.complement())
                .city(req.city())
                .state(req.state())
                .zipCode(req.zipCode())
                .active(true)
                .emailVerified(false)
                .build();

        return UserDTO.from(repo.save(entity));
    }

    public UserDTO getById(UUID id) {
        return repo.findById(id)
                .map(UserDTO::from)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
    }
}
