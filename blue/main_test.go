package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestHealthHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(healthHandler)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	var response HealthResponse
	if err := json.Unmarshal(rr.Body.Bytes(), &response); err != nil {
		t.Fatal(err)
	}

	expectedStatus := "healthy"
	if response.Status != expectedStatus {
		t.Errorf("handler returned unexpected status: got %v want %v",
			response.Status, expectedStatus)
	}

	expectedColor := "blue"
	if response.Color != expectedColor {
		t.Errorf("handler returned unexpected color: got %v want %v",
			response.Color, expectedColor)
	}

	expectedVersion := "1.0.0"
	if response.Version != expectedVersion {
		t.Errorf("handler returned unexpected version: got %v want %v",
			response.Version, expectedVersion)
	}

	// Check that timestamp is recent
	if time.Since(response.Timestamp) > 5*time.Second {
		t.Errorf("timestamp is too old: %v", response.Timestamp)
	}

	// Check that uptime is present
	if response.Uptime == "" {
		t.Error("uptime should not be empty")
	}
}

func TestRootHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(rootHandler)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	var response Response
	if err := json.Unmarshal(rr.Body.Bytes(), &response); err != nil {
		t.Fatal(err)
	}

	expectedMessage := "Hello from BLUE v1.0"
	if response.Message != expectedMessage {
		t.Errorf("handler returned unexpected message: got %v want %v",
			response.Message, expectedMessage)
	}

	expectedColor := "blue"
	if response.Color != expectedColor {
		t.Errorf("handler returned unexpected color: got %v want %v",
			response.Color, expectedColor)
	}

	expectedVersion := "1.0.0"
	if response.Version != expectedVersion {
		t.Errorf("handler returned unexpected version: got %v want %v",
			response.Version, expectedVersion)
	}

	// Check that timestamp is recent
	if time.Since(response.Timestamp) > 5*time.Second {
		t.Errorf("timestamp is too old: %v", response.Timestamp)
	}
}

func TestGetUptime(t *testing.T) {
	// Test uptime formatting
	uptime := getUptime()
	if uptime == "" {
		t.Error("uptime should not be empty")
	}

	// Test that uptime contains expected format
	if len(uptime) < 2 {
		t.Errorf("uptime should be at least 2 characters: %s", uptime)
	}
}

func TestHealthHandlerContentType(t *testing.T) {
	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(healthHandler)

	handler.ServeHTTP(rr, req)

	expectedContentType := "application/json"
	if contentType := rr.Header().Get("Content-Type"); contentType != expectedContentType {
		t.Errorf("handler returned wrong content type: got %v want %v",
			contentType, expectedContentType)
	}

	expectedCacheControl := "no-cache"
	if cacheControl := rr.Header().Get("Cache-Control"); cacheControl != expectedCacheControl {
		t.Errorf("handler returned wrong cache control: got %v want %v",
			cacheControl, expectedCacheControl)
	}
}

func TestRootHandlerContentType(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(rootHandler)

	handler.ServeHTTP(rr, req)

	expectedContentType := "application/json"
	if contentType := rr.Header().Get("Content-Type"); contentType != expectedContentType {
		t.Errorf("handler returned wrong content type: got %v want %v",
			contentType, expectedContentType)
	}
} 