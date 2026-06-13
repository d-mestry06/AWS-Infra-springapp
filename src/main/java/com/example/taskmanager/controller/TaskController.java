package com.example.taskmanager.controller;

import com.example.taskmanager.model.Task;
import com.example.taskmanager.repository.TaskRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@CrossOrigin(origins = "*")
public class TaskController {

    private final TaskRepository repository;

    public TaskController(TaskRepository repository) {
        this.repository = repository;
    }

    // ALB health check hits GET /  → must return 200
    //@GetMapping("/health")
    //public String healthCheck() {
   //     return "Task Manager is running!";
    //}

    // GET all tasks  (optional: /tasks?completed=true)
    @GetMapping("/tasks")
    public List<Task> getAllTasks(@RequestParam(required = false) Boolean completed) {
        if (completed != null) return repository.findByCompleted(completed);
        return repository.findAll();
    }

    // GET single task
    @GetMapping("/tasks/{id}")
    public ResponseEntity<Task> getTaskById(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST create task
    @PostMapping("/tasks")
    @ResponseStatus(HttpStatus.CREATED)
    public Task createTask(@RequestBody Task task) {
        return repository.save(task);
    }

    // PUT update / toggle task
    @PutMapping("/tasks/{id}")
    public ResponseEntity<Task> updateTask(@PathVariable Long id, @RequestBody Task updated) {
        return repository.findById(id).map(task -> {
            task.setDescription(updated.getDescription());
            task.setCompleted(updated.isCompleted());
            return ResponseEntity.ok(repository.save(task));
        }).orElse(ResponseEntity.notFound().build());
    }

    // DELETE task
    @DeleteMapping("/tasks/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        if (!repository.existsById(id)) return ResponseEntity.notFound().build();
        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
