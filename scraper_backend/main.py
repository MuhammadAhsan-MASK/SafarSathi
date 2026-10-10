from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from scraper import scrape_foodpanda

app = FastAPI(title="SastaSafar Scraper API")

# Setup CORS for local testing if needed
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Foodpanda Scraper API is running"}

@app.get("/api/restaurants")
async def get_restaurants(city: str):
    if not city:
        raise HTTPException(status_code=400, detail="City parameter is required")
        
    try:
        restaurants = await scrape_foodpanda(city)
        return {"city": city, "restaurants": restaurants}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
