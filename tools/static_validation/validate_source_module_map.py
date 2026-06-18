#!/usr/bin/env python3
"""Read-only static validation for source module map JSON (WP-10A-001)."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
SCHEMA_PATH = REPO_ROOT / "packages/source_module_map/source_module_map.schema.json"
EXAMPLE_PATH = REPO_ROOT / "packages/source_module_map/source_module_map.example.json"

REQUIRED_TOP_LEVEL = (
    "map_version",
    "source_files",
    "modules",
    "ownership",
    "test_mapping",
    "forbidden_paths",
)

SECRET_TOKENS = (
    "password",
    "secret",
    "token",
    "api_key",
    "private_key",
    "credential",
)


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def iter_nodes(value: Any, key: str | None = None):
    yield key, value
    if isinstance(value, dict):
        for child_key, child_value in value.items():
            yield from iter_nodes(child_value, child_key)
    elif isinstance(value, list):
        for item in value:
            yield from iter_nodes(item, key)


def contains_token(text: str, tokens: tuple[str, ...]) -> str | None:
    lowered = text.lower()
    for token in tokens:
        if token in lowered:
            return token
    return None


def validate_required_fields(document: dict[str, Any], errors: list[str]) -> None:
    for field in REQUIRED_TOP_LEVEL:
        if field not in document:
            errors.append(f"Missing required top-level field: {field}")
        elif document[field] in ("", None):
            errors.append(f"Required top-level field is empty: {field}")


def validate_forbidden_paths(document: dict[str, Any], errors: list[str]) -> None:
    forbidden_paths = document.get("forbidden_paths")
    if forbidden_paths is None:
        errors.append("Missing forbidden_paths")
        return
    if not isinstance(forbidden_paths, list):
        errors.append("forbidden_paths must be a list")
        return
    if not forbidden_paths:
        errors.append("forbidden_paths must not be empty")
        return
    if not all(isinstance(item, str) and item for item in forbidden_paths):
        errors.append("forbidden_paths must be a list of non-empty strings")


def validate_secret_patterns(document: dict[str, Any], errors: list[str]) -> None:
    for key, value in iter_nodes(document):
        if isinstance(key, str):
            matched = contains_token(key, SECRET_TOKENS)
            if matched:
                errors.append(f"Secret-like key detected: {key} (matched: {matched})")
        if isinstance(value, str):
            matched = contains_token(value, SECRET_TOKENS)
            if matched:
                errors.append(f"Secret-like value detected under key {key!r} (matched: {matched})")


def main() -> int:
    errors: list[str] = []

    if not SCHEMA_PATH.is_file():
        errors.append(f"Schema file not found: {SCHEMA_PATH}")
    if not EXAMPLE_PATH.is_file():
        errors.append(f"Example file not found: {EXAMPLE_PATH}")

    if errors:
        print("FAIL source module map validation")
        for error in errors:
            print(f"  - {error}")
        return 1

    try:
        load_json(SCHEMA_PATH)
    except json.JSONDecodeError as exc:
        errors.append(f"Schema JSON parse error: {exc}")

    try:
        example = load_json(EXAMPLE_PATH)
    except json.JSONDecodeError as exc:
        errors.append(f"Example JSON parse error: {exc}")
        example = None

    if not isinstance(example, dict):
        errors.append("Example root must be a JSON object")
    else:
        validate_required_fields(example, errors)
        validate_forbidden_paths(example, errors)
        validate_secret_patterns(example, errors)

    if errors:
        print("FAIL source module map validation")
        for error in errors:
            print(f"  - {error}")
        return 1

    print("PASS source module map validation")
    print(f"  schema:  {SCHEMA_PATH.relative_to(REPO_ROOT)}")
    print(f"  example: {EXAMPLE_PATH.relative_to(REPO_ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
