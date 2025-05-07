import requests
import json
import re
import datetime # Original import
import html
import firebase_admin
from datetime import datetime # Redundant, but present in notebook, will keep for now.
from firebase_admin import credentials, firestore, initialize_app


# GLOBAL VARIABLES AND MAPS
blog_category_map = {7: 'Advocacy', 456: 'Blog', 6: 'Campaigns', 256: 'Community',
                11: 'Conversion Therapy', 4: 'Donations', 8: 'Education',
                12: 'Events', 244: 'Gender Identity', 183: 'LGBTQ'}

blog_tag_map = {215: 'advocacy', 255: 'allyship', 278: 'anxious-feelings',
           530: 'bipoc', 259: 'bisexual', 436: 'blacktrevor', 281: 'brand',
           537: 'celebrities-creators', 246: 'coming-out', 437: 'communities-of-color'}

spanish_topic_map = {16: 'aliadx', 20: 'amigxs', 23: 'autoconocimiento',
                    25: 'autocuidado', 17: 'bisexual', 13: 'comunidad',
                    22: 'educacion-lgbtq', 15: 'expresion-de-genero',
                    21: 'familia', 14: 'hablar-de-suicidio',
                    10: 'orientacion-sexual', 11: 'salud-mental',
                    12: 'identidad-de-genero', 24: 'redes-sociales'}

resource_tags = {207: 'Ace Spectrum', 169: 'Adult Education', 177: 'Advocacy', 112: 'Ally', 208: 'Allyship', 201: 'Anxious Feelings', 189: 'Asexual', 205: 'BIPOC', 163: 'Bisexual', 158: 'Black'}
resource_categories = {176: 'Advocacy', 157: 'Ally', 161: 'Bisexual', 127: 'Conversion Therapy', 168: 'Education', 513: 'Family', 514: 'Friends', 101: 'Health', 88: 'LGBTQ+ Community Resources', 129: 'LGBTQ+ Mental Health Resources'}

API_ENDPOINTS = {
    "blog": "https://www.thetrevorproject.org/wp-json/wp/v2/posts/",
    "resource": "https://www.thetrevorproject.org/wp-json/wp/v2/trevor_rc_article/",
    "research": "https://www.thetrevorproject.org/wp-json/wp/v2/trevor_research/",
    "spanish": "https://www.thetrevorproject.mx/wp-json/wp/v2/resource/" # Note: from notebook
}

# Current date for filtering
params = {
    "per_page": 100,
    "page": 1,
    "_embed": True,
    # "after": f"{today}T00:00:00Z"  # Start of today
}

def format_date(date_string):
    """Format date from '2024-10-10T15:44:00' to 'October 10, 2024'"""
    try:
        date_obj = datetime.strptime(date_string, "%Y-%m-%dT%H:%M:%S")
        months = {
            1: "January", 2: "February", 3: "March", 4: "April",
            5: "May", 6: "June", 7: "July", 8: "August",
            9: "September", 10: "October", 11: "November", 12: "December"
        }
        month_name = months[date_obj.month]
        return f"{month_name} {date_obj.day}, {date_obj.year}"
    except Exception as e:
        print(f"Error formatting date '{date_string}': {e}")
        return date_string

def spanish_format_date(date_string):
    """Format date from '2024-10-10T15:44:00' to '10 de Octubre de 2024'"""
    try:
        date_obj = datetime.strptime(date_string, "%Y-%m-%dT%H:%M:%S")
        months = {
            1: "Enero", 2: "Febrero", 3: "Marzo", 4: "Abril",
            5: "Mayo", 6: "Junio", 7: "Julio", 8: "Agosto",
            9: "Septiembre", 10: "Octubre", 11: "Noviembre", 12: "Diciembre"
        }
        month_name = months[date_obj.month]
        # Corrected format to match typical Spanish date
        return f"{date_obj.day} de {month_name} de {date_obj.year}"
    except Exception as e:
        print(f"Error formatting Spanish date '{date_string}': {e}")
        return date_string


# This function fetches all blogs from the API and returns them as a list of dictionaries.
def get_blogs():
    try:
        response = requests.get(API_ENDPOINTS["blog"], params=params, headers={"User-Agent": "Mozilla/5.0"})
        data = response.json()
        result = []

        if not isinstance(data, list):
            print(f"Unexpected data format for blogs: {type(data)}")
            return []

        for item in data:
            if not isinstance(item, dict):
                continue

            title = html.unescape(item.get("title", {}).get("rendered", ""))
            title = re.sub(r'<[^>]+>', '', title)

            blog = {
                "title": title,
                "date": format_date(item.get("date", "")),
                "photo": None,
                "categories": [],
                "url": item.get("link", "")
            }

            if "_embedded" in item and "wp:featuredmedia" in item["_embedded"]:
                if item["_embedded"]["wp:featuredmedia"]:
                    blog["photo"] = item["_embedded"]["wp:featuredmedia"][0].get("source_url")

            if not blog["photo"] and "yoast_head_json" in item:
                if "og_image" in item["yoast_head_json"]:
                    images = item["yoast_head_json"].get("og_image", [])
                    if images and isinstance(images, list) and len(images) > 0:
                        blog["photo"] = images[0].get("url")

            if "_embedded" in item and "wp:term" in item["_embedded"]:
                for term_group in item["_embedded"]["wp:term"]:
                    if not isinstance(term_group, list):
                        continue
                    for term in term_group:
                        if not isinstance(term, dict):
                            continue
                        if term.get("taxonomy") == "category":
                            cat_id = term.get("id")
                            if cat_id in blog_category_map:
                                cat_name = blog_category_map[cat_id]
                                if cat_name not in blog["categories"]:
                                    blog["categories"].append(cat_name)
                            else:
                                term_name = term.get("name")
                                if term_name and term_name not in blog["categories"]:
                                    blog["categories"].append(term_name)
                        elif term.get("taxonomy") == "post_tag":
                            tag_id = term.get("id")
                            if tag_id in blog_tag_map:
                                tag_name = blog_tag_map[tag_id]
                                if tag_name not in blog["categories"]:
                                    blog["categories"].append(tag_name)
                            else:
                                term_name = term.get("name")
                                if term_name and term_name not in blog["categories"]:
                                    blog["categories"].append(term_name)

            if "categories" in item: # Fallback direct categories
                for cat_id in item["categories"]:
                    if cat_id in blog_category_map:
                        cat_name = blog_category_map[cat_id]
                        if cat_name not in blog["categories"]:
                            blog["categories"].append(cat_name)

            if "tags" in item: # Fallback direct tags
                for tag_id in item["tags"]:
                    if tag_id in blog_tag_map:
                        tag_name = blog_tag_map[tag_id]
                        if tag_name not in blog["categories"]:
                            blog["categories"].append(tag_name)

            blog["categories"] = [tag for tag in blog["categories"] if tag.lower() not in ["blog", "blogs"]]

            if "excerpt" in item and "rendered" in item["excerpt"]:
                excerpt = item["excerpt"]["rendered"]
                excerpt = re.sub(r'<[^>]+>', '', excerpt)
                excerpt = html.unescape(excerpt)
                blog["description"] = excerpt.strip()

            result.append(blog)

        print(f"Found {len(result)} blog posts (page {params.get('page', 1)})")
        return result
    except Exception as e:
        import traceback
        traceback.print_exc()
        print(f"Error parsing blogs: {e}")
        return []



def get_research_briefs():
    try:
        response = requests.get(API_ENDPOINTS["research"], params=params, headers={"User-Agent": "Mozilla/5.0"})
        data = response.json()
        result = []

        if not isinstance(data, list):
            print(f"Unexpected data format for research briefs: {type(data)}")
            return []

        for item in data:
            if not isinstance(item, dict):
                continue

            is_research = False
            if "_embedded" in item and "wp:term" in item["_embedded"]:
                for term_group in item["_embedded"]["wp:term"]:
                    if not isinstance(term_group, list): continue
                    for term in term_group:
                        if not isinstance(term, dict): continue
                        if term.get("taxonomy") == "category" and term.get("slug") in ["research", "research-briefs"]:
                            is_research = True
                            break
                    if is_research:
                        break

            link = item.get("link", "").lower()
            title_raw = item.get("title", {}).get("rendered", "").lower()
            if "research-brief" in link or "research-briefs" in link or "research brief" in title_raw:
                is_research = True

            if is_research:
                title = html.unescape(item.get("title", {}).get("rendered", ""))
                title = re.sub(r'<[^>]+>', '', title)

                brief = {
                    "title": title,
                    "date": format_date(item.get("date", "")),
                    "date_unformatted": item.get("date", ""),
                    "url": item.get("link", ""),
                    "photo": None # Initialize photo
                }

                if "_embedded" in item and "wp:featuredmedia" in item["_embedded"]:
                    if item["_embedded"]["wp:featuredmedia"]:
                        brief["photo"] = item["_embedded"]["wp:featuredmedia"][0].get("source_url")

                if not brief.get("photo") and "yoast_head_json" in item:
                    if "og_image" in item["yoast_head_json"]:
                        images = item["yoast_head_json"].get("og_image", [])
                        if images and isinstance(images, list) and len(images) > 0:
                            brief["photo"] = images[0].get("url")

                if "excerpt" in item and "rendered" in item["excerpt"]:
                    excerpt = item["excerpt"]["rendered"]
                    excerpt = re.sub(r'<[^>]+>', '', excerpt)
                    excerpt = html.unescape(excerpt)
                    brief["description"] = excerpt.strip()

                result.append(brief)

        print(f"Found {len(result)} research briefs (page {params.get('page', 1)})")
        return result
    except Exception as e:
        import traceback
        traceback.print_exc()
        print(f"Error parsing research briefs: {e}")
        return []


def get_resources():
    try:
        response = requests.get(API_ENDPOINTS["resource"], params=params, headers={"User-Agent": "Mozilla/5.0"})
        data = response.json()
        result = []

        if not isinstance(data, list):
             print(f"Error: JSON data for resources is not a list. Type: {type(data)}")
             return []

        for item in data:
            if not isinstance(item, dict) or "id" not in item or "slug" not in item:
                print(f"Skipping invalid resource item: {item}")
                continue

            title = item.get("title", {}).get("rendered", "")
            title = re.sub(r'<[^>]+>', '', title)
            title = html.unescape(title)
            resource = {
                "title": title,
                "date": format_date(item.get("date", "")),
                "date_unformatted" : item.get("date", ""),
                "photo": None,
                "categories": [],
                "url": item.get("link", ""),
                "description": ""
            }

            if "_embedded" in item and "wp:featuredmedia" in item["_embedded"]:
                if item["_embedded"]["wp:featuredmedia"]:
                    if isinstance(item["_embedded"]["wp:featuredmedia"], list) and len(item["_embedded"]["wp:featuredmedia"]) > 0:
                         resource["photo"] = item["_embedded"]["wp:featuredmedia"][0].get("source_url")

            if not resource["photo"] and "yoast_head_json" in item:
                if "og_image" in item["yoast_head_json"]:
                    images = item["yoast_head_json"].get("og_image", [])
                    if images and isinstance(images, list) and len(images) > 0:
                        resource["photo"] = images[0].get("url")

            embedded_terms_found = False
            if "_embedded" in item and "wp:term" in item["_embedded"]:
                if isinstance(item["_embedded"]["wp:term"], list):
                    for term_list in item["_embedded"]["wp:term"]:
                         if isinstance(term_list, list):
                            for term in term_list:
                                taxonomy = term.get("taxonomy")
                                if taxonomy in ["trevor_rc__category", "trevor_rc__tag"]: # Corrected taxonomies
                                    term_name = term.get("name")
                                    if term_name and term_name not in resource["categories"]:
                                        resource["categories"].append(term_name)
                                        embedded_terms_found = True

            if not embedded_terms_found:
                category_ids = item.get("trevor_rc__category", [])
                tag_ids = item.get("trevor_rc__tag", []) # Assuming this is the key for tags

                if isinstance(category_ids, list):
                    for cat_id in category_ids:
                        category_name = resource_categories.get(cat_id) # Using resource_categories map
                        if category_name and category_name not in resource["categories"]:
                            resource["categories"].append(category_name)

                if isinstance(tag_ids, list):
                    for tag_id in tag_ids:
                        tag_name = resource_tags.get(tag_id) # Using resource_tags map
                        if tag_name and tag_name not in resource["categories"]:
                            resource["categories"].append(tag_name)

            if "excerpt" in item and "rendered" in item["excerpt"]:
                excerpt = item["excerpt"]["rendered"]
                excerpt = re.sub(r'<[^>]+>', '', excerpt)
                excerpt = html.unescape(excerpt)
                resource["description"] = excerpt.strip()
            result.append(resource)

        print(f"Processed {len(result)} resource items (page {params.get('page', 1)})")
        return result
    except json.JSONDecodeError:
        print(f"Error: Could not decode JSON from resources endpoint.")
        return []
    except Exception as e:
        import traceback
        traceback.print_exc()
        print(f"An unexpected error occurred in get_resources: {e}")
        return []


def get_spanish_resources():
    try:
        response = requests.get(API_ENDPOINTS["spanish"], params=params, headers={"User-Agent": "Mozilla/5.0"})
        data = response.json()
        result = []

        # The spanish_topic_map is used as category_map here
        category_map = spanish_topic_map

        if isinstance(data, str): # API returned error string
            print(f"API returned a string for Spanish resources: {data}")
            return []
        if isinstance(data, dict) and "items" in data : # Handle if data is dict with "items"
             data = data["items"]
        elif not isinstance(data, list):
            print(f"API returned unexpected format for Spanish resources: {type(data)}")
            return []

        for item in data:
            if not isinstance(item, dict):
                print(f"Skipping non-dictionary Spanish item: {item}")
                continue

            # In the notebook, Spanish resources type is "resource"
            if item.get("type") == "resource":
                title_data = item.get("title", {})
                if isinstance(title_data, str):
                    title_text = title_data
                else:
                    title_text = title_data.get("rendered", "")

                title_text = re.sub(r'<[^>]+>', '', title_text)
                title_text = html.unescape(title_text)

                spanish_resource = {
                    "title": title_text,
                    "date": format_date(item.get("date", "")),
                    "date_spanish": spanish_format_date(item.get("date", "")),
                    "date_unformatted": item.get("date", ""),
                    "photo": None,
                    "categories": [],
                    "url": item.get("link", "")
                }

                if "_embedded" in item and "wp:featuredmedia" in item["_embedded"]:
                    media = item["_embedded"]["wp:featuredmedia"]
                    if media and isinstance(media, list) and len(media) > 0:
                        spanish_resource["photo"] = media[0].get("source_url")
                elif "jetpack_featured_media_url" in item: # Fallback
                    spanish_resource["photo"] = item["jetpack_featured_media_url"]

                if "_embedded" in item and "wp:term" in item["_embedded"]:
                    for term_list in item["_embedded"]["wp:term"]:
                        if isinstance(term_list, list):
                            for term in term_list:
                                # Spanish resources use 'topic' taxonomy
                                if term.get("taxonomy") == "topic":
                                    topic_id = term.get("id")
                                    if topic_id in category_map:
                                        topic_name = category_map[topic_id]
                                        if topic_name not in spanish_resource["categories"]:
                                            spanish_resource["categories"].append(topic_name)
                                    else: # Fallback to term name
                                        term_name = term.get("name")
                                        if term_name and term_name not in spanish_resource["categories"]:
                                            spanish_resource["categories"].append(term_name)

                # Fallback to direct 'topic' field
                if not spanish_resource["categories"] and "topic" in item:
                    topic_ids = item["topic"]
                    if isinstance(topic_ids, int): topic_ids = [topic_ids] # Handle single ID
                    if isinstance(topic_ids, list):
                        for topic_id in topic_ids:
                            if topic_id in category_map and category_map[topic_id] not in spanish_resource["categories"]:
                                spanish_resource["categories"].append(category_map[topic_id])

                excerpt_data = item.get("excerpt", {})
                if isinstance(excerpt_data, str):
                    excerpt_text = excerpt_data
                elif isinstance(excerpt_data, dict) and "rendered" in excerpt_data:
                    excerpt_text = excerpt_data["rendered"]
                else:
                    excerpt_text = ""

                if excerpt_text:
                    excerpt_text = re.sub(r'<[^>]+>', '', excerpt_text)
                    excerpt_text = html.unescape(excerpt_text)
                    spanish_resource["description"] = excerpt_text.strip()

                result.append(spanish_resource)

        print(f"Found {len(result)} Spanish resources (page {params.get('page', 1)})")
        return result
    except Exception as e:
        import traceback
        traceback.print_exc()
        print(f"Error parsing Spanish resources: {e}")
        return []


def get_all_blogs(max_pages=10):
    all_blogs = []
    page = 1
    per_page = 100
    seen_ids = set()

    while True:
        print(f"Fetching blog posts page {page}...")
        page_params = {
            "per_page": per_page,
            "page": page,
            "_embed": 1,
            "orderby": "date",
            "order": "desc"
        }
        try:
            response = requests.get(API_ENDPOINTS["blog"], params=page_params, headers={"User-Agent": "Mozilla/5.0"})
            if not response.ok:
                print(f"API request failed for all_blogs with status code {response.status_code}")
                break
            data = response.json()
            if not data or not isinstance(data, list) or len(data) == 0:
                print("No more blog posts found.")
                break

            new_posts_count = 0
            for item in data:
                if not isinstance(item, dict): continue
                post_id = item.get("id")
                if post_id in seen_ids: continue
                if post_id: seen_ids.add(post_id)

                title = html.unescape(item.get("title", {}).get("rendered", ""))
                title = re.sub(r'<[^>]+>', '', title)
                blog = {
                    "id": post_id, "title": title,
                    "date": format_date(item.get("date", "")),
                    "date_unformatted": item.get("date", ""),
                    "photo": None, "categories": [],
                    "url": item.get("link", "")
                }
                if "_embedded" in item and "wp:featuredmedia" in item["_embedded"]:
                    if item["_embedded"]["wp:featuredmedia"]:
                        blog["photo"] = item["_embedded"]["wp:featuredmedia"][0].get("source_url")
                if not blog["photo"] and "yoast_head_json" in item:
                    if "og_image" in item["yoast_head_json"]:
                        images = item["yoast_head_json"].get("og_image", [])
                        if images and isinstance(images, list) and len(images) > 0:
                            blog["photo"] = images[0].get("url")

                # Categories and tags processing (condensed from get_blogs)
                if "_embedded" in item and "wp:term" in item["_embedded"]:
                    for term_group in item["_embedded"]["wp:term"]:
                        if not isinstance(term_group, list): continue
                        for term in term_group:
                            if not isinstance(term, dict): continue
                            if term.get("taxonomy") == "category":
                                cat_id = term.get("id")
                                name_to_add = blog_category_map.get(cat_id, term.get("name"))
                                if name_to_add and name_to_add not in blog["categories"]: blog["categories"].append(name_to_add)
                            elif term.get("taxonomy") == "post_tag":
                                tag_id = term.get("id")
                                name_to_add = blog_tag_map.get(tag_id, term.get("name"))
                                if name_to_add and name_to_add not in blog["categories"]: blog["categories"].append(name_to_add)

                blog["categories"] = [tag for tag in blog["categories"] if tag.lower() not in ["blog", "blogs"]]

                if "excerpt" in item and "rendered" in item["excerpt"]:
                    excerpt = item["excerpt"]["rendered"]
                    excerpt = re.sub(r'<[^>]+>', '', excerpt)
                    excerpt = html.unescape(excerpt)
                    blog["description"] = excerpt.strip()

                all_blogs.append(blog)
                new_posts_count += 1

            print(f"Found {new_posts_count} new posts on page {page}.")
            if len(data) < per_page:
                print("Reached last page of blog results.")
                break
            if page >= max_pages:
                print(f"Reached maximum page limit ({max_pages}) for blogs.")
                break
            page += 1
        except Exception as e:
            import traceback
            traceback.print_exc()
            print(f"Error fetching blogs page {page}: {e}")
            break
    print(f"Total unique blog posts found: {len(all_blogs)}")
    return all_blogs


db = None
if not firebase_admin._apps:
    try:
        cred_path = "trevor_project_firebase_sdk.json"
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print(f"Firebase Admin SDK initialized with service account key: {cred_path}")
        db = firestore.client()
    except FileNotFoundError:
        print(f"Error: Firebase SDK file not found at {cred_path}. Trying default initialization.")
        try:
            firebase_admin.initialize_app() # Try with GOOGLE_APPLICATION_CREDENTIALS
            print("Firebase Admin SDK initialized with default credentials.")
            db = firestore.client()
        except Exception as e_default:
            print(f"Failed to initialize Firebase with default credentials: {e_default}")
            print("Firebase could not be initialized. Upload functionality will be disabled.")
    except ValueError as ve: # Handles already initialized error if script is re-run in some environments
        print(f"Firebase initialization ValueError: {ve}")
        if firebase_admin._apps: # If it was a ValueError due to re-initialization, get the client
            db = firestore.client()
        else:
            print("Firebase could not be initialized. Upload functionality will be disabled.")
    except Exception as e_manual:
        print(f"Failed to initialize Firebase with service account key '{cred_path}': {e_manual}")
        print("Firebase could not be initialized. Upload functionality will be disabled.")
else: # Already initialized
    db = firestore.client()
    print("Firebase Admin SDK was already initialized.")


def upload_to_firebase(data, collection_name):
    if not db:
        print(f"Firestore client not available. Skipping upload for {collection_name}.")
        return

    batch = db.batch()
    # Reference to the subcollection of articles
    # Main collection 'resourcesPage' -> document for each type (e.g., 'Blogs') -> subcollection 'articles'
    articles_ref = db.collection('resourcesPage').document(collection_name).collection('articles')

    count = 0
    for item_data in data:
        # Create a new document with auto-generated ID in the 'articles' subcollection
        doc_ref = articles_ref.document()
        batch.set(doc_ref, item_data)
        count += 1
        if count % 499 == 0:  # Firestore batch limit is 500 operations
            print(f"Committing batch of {count % 499 or 499} items to {collection_name}...")
            batch.commit()
            batch = db.batch() # Start a new batch

    if count % 499 != 0: # Commit any remaining writes
        print(f"Committing final batch of {count % 499} items to {collection_name}...")
        batch.commit()
    print(f"Successfully uploaded {count} items to {collection_name} under resourcesPage/{collection_name}/articles")


def main():
    collection_mappings = [
        {"func" : get_all_blogs, "collection": "Blogs", "params": {"max_pages": 20}}, # Example of passing params
        {"func" : get_research_briefs, "collection": "Research Briefs"},
        {"func" : get_resources, "collection": "Resource Center"},
        {"func" : get_spanish_resources, "collection": "SpanishResources"},
    ]

    for mapping in collection_mappings:
        print(f"Processing for {mapping['collection']}...")

        func_to_call = mapping["func"]
        func_params = mapping.get("params", {}) # Get specific params for the function if any

        # Call the function with its specific parameters
        if func_params:
             data = func_to_call(**func_params)
        else:
             data = func_to_call()

        if data: # Check if data is not None and not empty
            print(f"Found {len(data)} items for {mapping['collection']}")
            upload_to_firebase(data, mapping["collection"])
        else:
            print(f"No data found or error processing {mapping['collection']}")

if __name__ == "__main__":
    main()
