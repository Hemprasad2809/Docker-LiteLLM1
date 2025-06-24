#!/usr/bin/env python3
"""
Health check script for LiteLLM Proxy
Tests the health endpoint and provides detailed status information
"""

import requests
import json
import time
import sys

def test_health_endpoint(url="http://localhost:5000/health", timeout=10):
    """Test the health endpoint of LiteLLM Proxy"""
    try:
        print(f"Testing health endpoint: {url}")
        response = requests.get(url, timeout=timeout)
        
        if response.status_code == 200:
            print("✅ Health check PASSED")
            print(f"Status Code: {response.status_code}")
            print(f"Response: {response.text}")
            return True
        else:
            print("❌ Health check FAILED")
            print(f"Status Code: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection Error: Cannot connect to LiteLLM Proxy")
        print("Make sure the container is running on port 5000")
        return False
    except requests.exceptions.Timeout:
        print("❌ Timeout Error: Health check timed out")
        return False
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

def test_additional_endpoints():
    """Test additional LiteLLM endpoints"""
    base_url = "http://localhost:5000"
    endpoints = [
        "/health",
        "/health/liveliness", 
        "/health/readiness",
        "/models"
    ]
    
    print("\n🔍 Testing additional endpoints:")
    for endpoint in endpoints:
        url = base_url + endpoint
        try:
            response = requests.get(url, timeout=5)
            status = "✅" if response.status_code == 200 else "❌"
            print(f"{status} {endpoint}: {response.status_code}")
        except:
            print(f"❌ {endpoint}: Connection failed")

if __name__ == "__main__":
    print("🚀 LiteLLM Proxy Health Check")
    print("=" * 40)
    
    # Wait a bit for container to fully start
    print("Waiting 5 seconds for container to start...")
    time.sleep(5)
    
    # Test health endpoint
    success = test_health_endpoint()
    
    if success:
        print("\n🎉 LiteLLM Proxy is running successfully!")
        test_additional_endpoints()
    else:
        print("\n💡 Troubleshooting tips:")
        print("1. Check if container is running: docker ps")
        print("2. Check container logs: docker-compose logs")
        print("3. Ensure port 5000 is not in use by another service")
        sys.exit(1) 