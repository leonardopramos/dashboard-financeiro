package com.dashboard_financeiro.cadastroautenticacao.web.controller;

import com.dashboard_financeiro.cadastroautenticacao.application.UserService;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.CreateUserRequest;
import com.dashboard_financeiro.cadastroautenticacao.web.dto.UserDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService service;

    @PostMapping
    public ResponseEntity<UserDTO> register(@Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.register(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }
}
