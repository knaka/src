// Code generated by sqlc-gen-ts-d1. DO NOT EDIT.
// versions:
//   sqlc v1.27.0
//   sqlc-gen-ts-d1 v0.0.0-a@dfd4bfef4736967ca17cc23d18de20920fbd196998fe7aa191a205439d63fb58

import { D1Database, D1PreparedStatement, D1Result } from "@cloudflare/workers-types/2022-11-30"

type Query<T> = {
  then(onFulfilled?: (value: T) => void, onRejected?: (reason?: any) => void): void;
  batch(): D1PreparedStatement;
}
const getUserQuery = `-- name: GetUser :one
SELECT id, username, updated_at, created_at
FROM users
WHERE
  CASE WHEN CAST(?1 AS integer) IS NOT NULL THEN id = ?1 ELSE false END OR
  CASE WHEN CAST(?2 AS string) IS NOT NULL THEN username = ?2 ELSE false END
LIMIT 1`;

export type GetUserParams = {
  nullableId?: number | null;
  nullableUsername?: number | string | null;
};

export type GetUserRow = {
  id: number;
  username: number | string;
  updatedAt: string;
  createdAt: string;
};

type RawGetUserRow = {
  id: number;
  username: number | string;
  updated_at: string;
  created_at: string;
};

export function getUser(
  d1: D1Database,
  args: GetUserParams
): Query<GetUserRow | null> {
  const ps = d1
    .prepare(getUserQuery)
    .bind(typeof args.nullableId === "undefined"? null: args.nullableId,typeof args.nullableUsername === "undefined"? null: args.nullableUsername);
  return {
    then(onFulfilled?: (value: GetUserRow | null) => void, onRejected?: (reason?: any) => void) {
      ps.first<RawGetUserRow | null>()
        .then((raw: RawGetUserRow | null) => raw ? {
          id: raw.id,
          username: raw.username,
          updatedAt: raw.updated_at,
          createdAt: raw.created_at,
        } : null)
        .then(onFulfilled).catch(onRejected);
    },
    batch() { return ps; },
  }
}

const getTheUserQuery = `-- name: GetTheUser :many
;

SELECT id, username, updated_at, created_at
FROM users
WHERE
  id = ?1`;

export type GetTheUserParams = {
  id: number;
};

export type GetTheUserRow = {
  id: number;
  username: number | string;
  updatedAt: string;
  createdAt: string;
};

type RawGetTheUserRow = {
  id: number;
  username: number | string;
  updated_at: string;
  created_at: string;
};

export function getTheUser(
  d1: D1Database,
  args: GetTheUserParams
): Query<D1Result<GetTheUserRow>> {
  const ps = d1
    .prepare(getTheUserQuery)
    .bind(typeof args.id === "undefined"? null: args.id);
  return {
    then(onFulfilled?: (value: D1Result<GetTheUserRow>) => void, onRejected?: (reason?: any) => void) {
      ps.all<RawGetTheUserRow>()
        .then((r: D1Result<RawGetTheUserRow>) => { return {
          ...r,
          results: r.results.map((raw: RawGetTheUserRow) => { return {
            id: raw.id,
            username: raw.username,
            updatedAt: raw.updated_at,
            createdAt: raw.created_at,
          }}),
        }})
        .then(onFulfilled).catch(onRejected);
    },
    batch() { return ps; },
  }
}

const addUserQuery = `-- name: AddUser :exec
;

INSERT INTO users (username) VALUES (?1)`;

export type AddUserParams = {
  username: number | string;
};

export function addUser(
  d1: D1Database,
  args: AddUserParams
): Query<D1Result> {
  const ps = d1
    .prepare(addUserQuery)
    .bind(typeof args.username === "undefined"? null: args.username);
  return {
    then(onFulfilled?: (value: D1Result) => void, onRejected?: (reason?: any) => void) {
      ps.run()
        .then(onFulfilled).catch(onRejected);
    },
    batch() { return ps; },
  }
}

