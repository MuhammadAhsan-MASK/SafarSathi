import asyncio
from playwright.async_api import async_playwright

async def scrape_foodpanda(city: str):
    """
    Scrapes the foodpanda website for the given city and returns a list of restaurants.
    This is a basic scraper using Playwright to handle dynamic content.
    """
    url = f"https://www.foodpanda.pk/city/{city.lower()}"
    
    restaurants = []
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        try:
            # Go to the targeted city page
            await page.goto(url, wait_until="domcontentloaded", timeout=30000)
            
            # Wait for some restaurant cards to load
            # Foodpanda uses dynamic classes, but we can look for generic lists or figure-based cards
            # A common class for restaurant items is 'vendor-list' or similar
            try:
                await page.wait_for_selector('ul.vendor-list li', timeout=10000)
            except:
                # If specifically 'vendor-list' isn't found, try waiting for any link that might be a vendor
                await page.wait_for_selector('figure', timeout=10000)
            
            # Extract basic data
            # Foodpanda restaurant cards typically have a link wrapping a figure/image and text info
            elements = await page.query_selector_all('li.vendor-tile-new, figure, [data-testid="vendor-list-item"]')
            
            for index, el in enumerate(elements):
                if index >= 20: # limit to top 20
                    break
                    
                try:
                    # Look for title inside element
                    title_el = await el.query_selector('span.name, span.vendor-name, h3')
                    title = await title_el.inner_text() if title_el else "Unknown Restaurant"
                    
                    # Look for rating
                    rating_el = await el.query_selector('span.rating, span.badge-label, [data-testid="rating"]')
                    rating = await rating_el.inner_text() if rating_el else "New"
                    
                    # Look for image
                    img_el = await el.query_selector('img')
                    img_url = await img_el.get_attribute('src') if img_el else ""
                    
                    restaurants.append({
                        "id": f"{city}-{index}",
                        "name": title.strip(),
                        "rating": rating.strip(),
                        "image_url": img_url,
                    })
                except Exception as inner_e:
                    # Skip problematic element
                    continue
                    
        except Exception as e:
            print(f"Error scraping {city}: {e}")
        finally:
            await browser.close()
            
    return restaurants
