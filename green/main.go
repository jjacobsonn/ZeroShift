package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

type HealthResponse struct {
	Status    string    `json:"status"`
	Version   string    `json:"version"`
	Color     string    `json:"color"`
	Timestamp time.Time `json:"timestamp"`
	Uptime    string    `json:"uptime"`
}

type Response struct {
	Message   string    `json:"message"`
	Version   string    `json:"version"`
	Color     string    `json:"color"`
	Timestamp time.Time `json:"timestamp"`
}

var startTime = time.Now()

func getUptime() string {
	duration := time.Since(startTime)
	days := int(duration.Hours() / 24)
	hours := int(duration.Hours()) % 24
	minutes := int(duration.Minutes()) % 60
	seconds := int(duration.Seconds()) % 60
	
	if days > 0 {
		return fmt.Sprintf("%dd %dh %dm %ds", days, hours, minutes, seconds)
	} else if hours > 0 {
		return fmt.Sprintf("%dh %dm %ds", hours, minutes, seconds)
	} else if minutes > 0 {
		return fmt.Sprintf("%dm %ds", minutes, seconds)
	}
	return fmt.Sprintf("%ds", seconds)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-cache")
	
	response := HealthResponse{
		Status:    "healthy",
		Version:   "1.0.0",
		Color:     "green",
		Timestamp: time.Now(),
		Uptime:    getUptime(),
	}
	
	json.NewEncoder(w).Encode(response)
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	response := Response{
		Message:   "Hello from GREEN v1.0",
		Version:   "1.0.0",
		Color:     "green",
		Timestamp: time.Now(),
	}
	
	json.NewEncoder(w).Encode(response)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8082"
	}
	
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/health", healthHandler)
	
	log.Printf("🚀 Green server starting on port %s", port)
	log.Printf("📊 Health endpoint: http://localhost:%s/health", port)
	log.Printf("🌐 Main endpoint: http://localhost:%s/", port)
	
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("Failed to start server:", err)
	}
} 