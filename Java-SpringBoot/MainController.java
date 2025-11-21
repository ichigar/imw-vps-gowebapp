package com.example.webapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class MainController {

    @GetMapping("/")
    public String index(Model model, HttpServletRequest request) {
        DateTimeFormatter formato = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        model.addAttribute("lenguaje", "Java - Spring Boot");
        model.addAttribute("fechaHora", LocalDateTime.now().format(formato));
        model.addAttribute("ip", request.getRemoteAddr());
        model.addAttribute("navegador", request.getHeader("User-Agent"));
        model.addAttribute("versionJava", System.getProperty("java.version"));
        return "index";
    }

    @GetMapping("/contacto")
    public String contacto() {
        return "contacto";
    }
}
