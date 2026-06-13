package com.example.taskmanager.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

// FIX: This file was empty. The ALB health check calls GET /health every 30s.
// Without this endpoint the app returned 404 (or no response if the app crashed),
// causing the target to be marked Unhealthy.
@RestController
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }
}