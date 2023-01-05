package com.example.demo;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
@RequestMapping("/")
public class DemoController {
    @GetMapping("/demo")
    public ResponseEntity<String> demo() {
        System.out.println("接收到请求");
        return ResponseEntity.ok("你好");
    }
}
