"""FastAPI application entry point."""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import structlog

from app.config import settings
from app.api.routes import leads, in_sequence, drafts, research, analytics, health, templates, webhooks, debug, emails
from app.dependencies import init_db

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events."""
    logger.info("Starting AI Sales Agent API")
    await init_db()
    yield
    logger.info("Shutting down AI Sales Agent API")


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="AI Sales Agent API",
        description="Production-ready multi-agent sales outreach system",
        version="0.1.0",
        lifespan=lifespan,
    )

    # CORS middleware - Security compliant
    if settings.cors_allow_all_origins:
        # When allowing all origins, disable credentials for security
        app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=False,  # Cannot use credentials with wildcard origins
            allow_methods=["*"],
            allow_headers=["*"],
        )
    else:
        # Use explicit origins with credentials enabled
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins_list,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    # Register routes
    app.include_router(health.router, tags=["Health"])
    app.include_router(leads.router, prefix="/api/v1/leads", tags=["Leads"])
    app.include_router(
        research.router, prefix="/api/v1/research", tags=["Research"])
    app.include_router(in_sequence.router,
                       prefix="/api/v1/in-sequence", tags=["In Sequence"])
    app.include_router(drafts.router, prefix="/api/v1/drafts", tags=["Drafts"])
    app.include_router(
        templates.router, prefix="/api/v1/templates", tags=["Templates"])
    app.include_router(
        analytics.router, prefix="/api/v1/analytics", tags=["Analytics"])
    app.include_router(
        webhooks.router, prefix="/api/v1/webhooks", tags=["Webhooks"])
    app.include_router(debug.router, prefix="/api/v1/debug", tags=["Debug"])
    app.include_router(emails.router, prefix="/api/v1", tags=["Emails"])

    # Backend serves API only - frontend is served by Nginx on port 3000
    logger.info(
        "Backend running in API-only mode. Frontend served on port 3000.")

    return app


app = create_app()
