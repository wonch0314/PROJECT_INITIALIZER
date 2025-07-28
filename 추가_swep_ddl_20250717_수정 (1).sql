DROP TABLE IF EXISTS tenant_project_joins;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS project_account_joins;
DROP TABLE IF EXISTS project_modules;
DROP TABLE IF EXISTS pages;
DROP TABLE IF EXISTS contents;
DROP TABLE IF EXISTS project_module_repo_joins;
DROP TABLE IF EXISTS project_item_repos;
DROP TABLE IF EXISTS service_codes;
DROP TABLE IF EXISTS agent_contents;
drop table if exists versions;

-- tenant_project_joins 생성
create table public.tenant_project_joins
(
    id         uuid                     default gen_random_uuid() not null
        primary key,
    tenant_id  varchar(36)                                        not null,
    project_id uuid                                               not null,
    created_at timestamp with time zone default CURRENT_TIMESTAMP,
    created_by uuid,
    updated_at timestamp with time zone default CURRENT_TIMESTAMP,
    updated_by uuid
);
comment on table public.tenant_project_joins is '테넌트와 프로젝트 간의 다대다 관계를 연결하는 조인 테이블입니다.';
comment on column public.tenant_project_joins.id is '조인 관계 고유 ID';
comment on column public.tenant_project_joins.tenant_id is '참조하는 테넌트 ID';
comment on column public.tenant_project_joins.project_id is '참조하는 프로젝트 ID';
comment on column public.tenant_project_joins.created_at is '조인 레코드 생성일시';
comment on column public.tenant_project_joins.created_by is '조인 레코드 생성자 ID';
comment on column public.tenant_project_joins.updated_at is '조인 레코드 최종 수정일시';
comment on column public.tenant_project_joins.updated_by is '조인 레코드 최종 수정자 ID';
alter table public.tenant_project_joins
    owner to aiplatform;
grant delete, insert, references, select, trigger, truncate, update on public.tenant_project_joins to aionu;
grant delete, insert, references, select, trigger, truncate, update on public.tenant_project_joins to aionu_user;

-- projects 생성
create table public.projects
(
    id          uuid                     default gen_random_uuid() not null
        primary key,
    tenant_id   uuid                                               not null,
    name        text                                               not null,
    description text,
    owner       uuid,
    information json                     default '{}'::json,
    efct_st_dt  timestamp with time zone,
    efct_fns_dt timestamp with time zone,
    created_at  timestamp with time zone default CURRENT_TIMESTAMP,
    created_by  uuid,
    updated_at  timestamp with time zone default CURRENT_TIMESTAMP,
    updated_by  uuid
);
comment on table public.projects is 'SWEP에서 사용자가 프로젝트를 관리하기 위한 단위입니다.';
comment on column public.projects.id is '프로젝트 고유 ID';
comment on column public.projects.tenant_id is '프로젝트가 속한 테넌트의 ID (직접 참조)';
comment on column public.projects.name is '프로젝트 이름';
comment on column public.projects.information is '프로젝트 정보';
comment on column public.projects.description is '프로젝트 설명';
comment on column public.projects.owner is '프로젝트 소유자(사용자) ID';
comment on column public.projects.efct_st_dt is '프로젝트 유효 시작일시';
comment on column public.projects.efct_fns_dt is '프로젝트 유효 종료일시';
comment on column public.projects.created_at is '프로젝트 레코드 생성일시';
comment on column public.projects.created_by is '프로젝트 레코드 생성자 ID';
comment on column public.projects.updated_at is '프로젝트 레코드 최종 수정일시';
comment on column public.projects.updated_by is '프로젝트 레코드 최종 수정자 ID';
alter table public.projects
    owner to aiplatform;
grant delete, insert, references, select, trigger, truncate, update on public.projects to aionu;
grant delete, insert, references, select, trigger, truncate, update on public.projects to aionu_user;

-- service_codes 테이블 생성
create table public.service_codes
(
    code        text                                               not null
        primary key,
    value       text                                               not null,
    parent_code text,
    "order"     integer                  default 1                 not null,
    depth       integer                  default 1                 not null,
    description text,
    efct_st_dt  timestamp without time zone                default CURRENT_TIMESTAMP not null,
    efct_fns_dt timestamp                default '9999-12-31 00:00:00'::timestamp without time zone not null,
    created_at  timestamp without time zone default CURRENT_TIMESTAMP not null,
    created_by  uuid,
    updated_at  timestamp without time zone default CURRENT_TIMESTAMP not null,
    updated_by  uuid
);

comment on table public.service_codes is '계층 구조를 가지는 공통 코드 관리 테이블';
comment on column public.service_codes.code is '코드 (PK)';
comment on column public.service_codes.value is '코드 값/이름';
comment on column public.service_codes.parent_code is '상위 코드 (FK)';
comment on column public.service_codes."order" is '정렬 순서';
comment on column public.service_codes.depth is '계층 깊이 (Depth)';
comment on column public.service_codes.description is '코드 설명';
comment on column public.service_codes.efct_st_dt is '유효시작일';
comment on column public.service_codes.efct_fns_dt is '유효종료일';
comment on column public.service_codes.created_at is '생성 시각';
comment on column public.service_codes.created_by is '생성자 UUID';
comment on column public.service_codes.updated_at is '수정 시각';
comment on column public.service_codes.updated_by is '수정자 UUID';
alter table public.service_codes
    owner to aiplatform;


-- project_account_joins
create table public.project_account_joins
(
    id          uuid                             not null
        primary key,
    project_id  uuid                             not null,
    account_id  uuid                             not null,
    role        text      default 'member'::text not null,
    efct_st_dt  timestamp,
    efct_fns_dt timestamp,
    created_at  timestamp without time zone default CURRENT_TIMESTAMP not null,
    created_by  uuid,
    updated_at  timestamp without time zone default CURRENT_TIMESTAMP not null,
    updated_by  uuid
);

comment on table public.project_account_joins is '프로젝트와 계정의 관계를 정의하는 조인 테이블';
comment on column public.project_account_joins.id is '고유 식별자 (PK)';
comment on column public.project_account_joins.project_id is '프로젝트의 ID';
comment on column public.project_account_joins.account_id is '계정의 ID';
comment on column public.project_account_joins.role is '프로젝트 내에서의 계정 역할';
comment on column public.project_account_joins.efct_st_dt is '관계 유효 시작 일시';
comment on column public.project_account_joins.efct_fns_dt is '관계 유효 종료 일시';
comment on column public.project_account_joins.created_at is '레코드 생성 일시';
comment on column public.project_account_joins.created_by is '레코드 생성자 ID';
comment on column public.project_account_joins.updated_at is '레코드 수정 일시';
comment on column public.project_account_joins.updated_by is '레코드 수정자 ID';
alter table public.project_account_joins
    owner to aiplatform;
grant delete, insert, references, select, trigger, truncate, update on public.project_account_joins to aionu;
grant delete, insert, references, select, trigger, truncate, update on public.project_account_joins to aionu_user;

-- project_modules
create table public.project_modules
(
    id             uuid                     default uuid_generate_v4()           not null
        primary key,
    project_id     uuid                                                          not null,
    parent_module_type    text                                                          not null,
    module_type    text                                                          not null,
    status         varchar(10)              default 'waiting'::character varying not null,
    progress       smallint                 default 0                            not null,
    version        text                     default '1.0.0' not null,
    efct_st_dt     timestamp,
    efct_fns_dt    timestamp,
    created_at     timestamp without time zone default CURRENT_TIMESTAMP not null,
    created_by     uuid,
    updated_at     timestamp without time zone default CURRENT_TIMESTAMP not null,
    updated_by     uuid
);

comment on table public.project_modules is 'SWEP 프로젝트의 하위 메뉴를 정의하는 테이블 (예: 코드 분석기, 요구사항 분석기)';
comment on column public.project_modules.id is '고유 식별자 (UUID)';
comment on column public.project_modules.project_id is '연결된 프로젝트의 ID';
comment on column public.project_modules.parent_module_type is '부모 모듈 유형 (예: "analysis_agents")';
comment on column public.project_modules.module_type is '모듈 유형 (예: "code-analyzer", "req-analyzer")';
comment on column public.project_modules.status is '모듈 처리 상태 (success, failed, processing, waiting)';
comment on column public.project_modules.progress is '모듈 진행 상태 (0~100)';
comment on column public.project_modules.version is '버전(1.0.0) 에이전트에 따라 2,3개';
comment on column public.project_modules.efct_st_dt is '유효 시작 일시';
comment on column public.project_modules.efct_fns_dt is '유효 종료 일시';
comment on column public.project_modules.created_at is '레코드 생성 일시';
comment on column public.project_modules.created_by is '레코드 생성 사용자 ID';
comment on column public.project_modules.updated_at is '레코드 최종 업데이트 일시';
comment on column public.project_modules.updated_by is '레코드 최종 업데이트 사용자 ID';
comment on column public.project_modules.version is '버전(1.0.0), 에이전트에 따라 2자리, 3자리';
alter table public.project_modules
    owner to aiplatform;
grant delete, insert, references, select, trigger, truncate, update on public.project_modules to aionu;
grant delete, insert, references, select, trigger, truncate, update on public.project_modules to aionu_user;

-- pages
create table public.pages
(
    id                uuid                     default gen_random_uuid() not null
        primary key,
    project_module_id uuid                                               not null,
    parent_id         uuid,
    title             text                                               not null,
    "order"           integer,
    version           text                     default '1.0.0' not null,
    created_at        timestamp without time zone default CURRENT_TIMESTAMP not null,
    created_by        uuid,
    updated_at        timestamp without time zone default CURRENT_TIMESTAMP not null,
    updated_by        uuid,
    content_id        uuid
);

comment on table public.pages is '프로젝트 모듈 내의 페이지 정보를 관리합니다. (deepwiki 구조를 따름)';
comment on column public.pages.id is '페이지 고유 ID';
comment on column public.pages.project_module_id is '소속 프로젝트 모듈 ID';
comment on column public.pages.parent_id is '상위 페이지 ID (NULL인 경우 최상위 페이지). id, parent_id 관계를 이용해 하위 페이지를 구성합니다.';
comment on column public.pages.title is '페이지 제목';
comment on column public.pages."order" is '동일 레벨 페이지 내에서의 표시 순서';
comment on column public.pages.created_at is '페이지 레코드 생성일시';
comment on column public.pages.created_by is '페이지 레코드 생성자 ID';
comment on column public.pages.updated_at is '페이지 레코드 최종 수정일시';
comment on column public.pages.updated_by is '페이지 레코드 최종 수정자 ID';
comment on column public.pages.version is '버전(1.0.0) 에이전트에 따라 2,3자리 저버전';
comment on column public.pages.content_id is '삭제 예정';
alter table public.pages
    owner to aiplatform;
grant delete, insert, references, select, trigger, truncate, update on public.pages to aionu;
grant delete, insert, references, select, trigger, truncate, update on public.pages to aionu_user;

-- contents
create table public.contents
(
    id             uuid                     default gen_random_uuid() not null
        primary key,
    content        text,
    rel_src_files  text[],
    page_id        uuid,
    version        text                     default '1.0.0' not null,
    created_at     timestamp without time zone default CURRENT_TIMESTAMP not null,
    created_by     uuid,
    updated_at     timestamp without time zone default CURRENT_TIMESTAMP not null,
    updated_by     uuid,
    efct_st_dt     timestamp without time zone default CURRENT_TIMESTAMP not null,
    efct_fns_dt    timestamp without time zone default '9999-12-31 00:00:00' not null
);

comment on table public.contents is '페이지의 실제 본문 내용과 관련 소스 파일 정보를 관리합니다.';
comment on column public.contents.id is '내용 고유 ID';
comment on column public.contents.content is '페이지의 실제 본문 내용. 실제 본문 자료는 별도 로드될 수 있습니다.';
comment on column public.contents.rel_src_files is '관련 소스 파일 경로 목록 (배열)';
comment on column public.contents.created_at is '내용 레코드 생성일시';
comment on column public.contents.created_by is '내용 레코드 생성자 ID';
comment on column public.contents.updated_at is '내용 레코드 최종 수정일시';
comment on column public.contents.updated_by is '내용 레코드 최종 수정자 ID';
comment on column public.contents.page_id is '페이지 아이디';
comment on column public.contents.version is '버전(1.0.0), 에이전트에 따라 2,3 자리';
alter table public.contents
    owner to aiplatform;
grant delete, insert, references, select, trigger, truncate, update on public.contents to aionu;
grant delete, insert, references, select, trigger, truncate, update on public.contents to aionu_user;

-- project_module_repo_joins
create table public.project_module_repo_joins
(
    id                   uuid                     default uuid_generate_v4() not null
        primary key,
    project_module_id    uuid                                                not null,
    project_item_repo_id uuid                                                not null,
    created_at           timestamp without time zone default CURRENT_TIMESTAMP not null,
    created_by           uuid,
    updated_at           timestamp without time zone default CURRENT_TIMESTAMP not null,
    updated_by           uuid
);
comment on table public.project_module_repo_joins is '프로젝트 모듈과 파일 저장소 간의 연결 관계를 정의하는 테이블';
comment on column public.project_module_repo_joins.id is '고유 식별자 (UUID)';
comment on column public.project_module_repo_joins.project_module_id is '연결된 project_modules 테이블의 ID';
comment on column public.project_module_repo_joins.project_item_repo_id is '연결된 project_item_repos 테이블의 ID';
comment on column public.project_module_repo_joins.created_at is '레코드 생성 일시';
comment on column public.project_module_repo_joins.created_by is '레코드 생성 사용자 ID';
comment on column public.project_module_repo_joins.updated_at is '레코드 최종 업데이트 일시';
comment on column public.project_module_repo_joins.updated_by is '레코드 최종 업데이트 사용자 ID';
alter table public.project_module_repo_joins
    owner to aiplatform;
grant delete, insert, references, select, trigger, truncate, update on public.project_module_repo_joins to aionu;
grant delete, insert, references, select, trigger, truncate, update on public.project_module_repo_joins to aionu_user;

-- project_item_repos
create table public.project_item_repos
(
    id                uuid                     default uuid_generate_v4() not null
        primary key,
    project_id        uuid                                                not null,
    repo_type         varchar(10)                                         not null,
    repo_name         text                                                not null,
    repo_path         text,
    repo_auth         jsonb,
    upload_file_id    uuid default null,
    project_module_id uuid default null,
    efct_st_dt        timestamp,
    efct_fns_dt       timestamp,
    created_at        timestamp without time zone default CURRENT_TIMESTAMP not null,
    created_by        uuid,
    updated_at        timestamp without time zone default CURRENT_TIMESTAMP not null,
    updated_by        uuid
);

comment on table public.project_item_repos is '프로젝트에 등록된 파일 저장소(Repository) 정보를 정의하는 테이블';
comment on column public.project_item_repos.id is '고유 식별자 (UUID)';
comment on column public.project_item_repos.project_id is '연결된 프로젝트의 ID (프로젝트 전체 단위로 파일 등록 절차 고려)';
comment on column public.project_item_repos.repo_type is '저장소 유형 (예: "zip", "gitlab", "github"). informations 테이블의 category=project_file_type으로 관리.';
comment on column public.project_item_repos.repo_name is '파일 또는 저장소의 이름';
comment on column public.project_item_repos.repo_path is '파일 또는 저장소의 경로';
comment on column public.project_item_repos.repo_auth is '인증 정보 (JSON 형식, 예: PAT, SSH 키)';
comment on column public.project_item_repos.efct_st_dt is '유효 시작 일시';
comment on column public.project_item_repos.efct_fns_dt is '유효 종료 일시';
comment on column public.project_item_repos.created_at is '레코드 생성 일시';
comment on column public.project_item_repos.created_by is '레코드 생성 사용자 ID';
comment on column public.project_item_repos.updated_at is '레코드 최종 업데이트 일시';
comment on column public.project_item_repos.updated_by is '레코드 최종 업데이트 사용자 ID';
comment on column public.project_item_repos.upload_file_id is '업로드 파일 아이디';
comment on column public.project_item_repos.project_module_id is '프로젝트 모듈 아이디';
alter table public.project_item_repos
    owner to aiplatform;
grant delete, insert, references, select, trigger, truncate, update on public.project_item_repos to aionu;
grant delete, insert, references, select, trigger, truncate, update on public.project_item_repos to aionu_user;

-- 버전 테이블 생성
CREATE TABLE versions (
    version_key uuid NOT NULL default uuid_generate_v4(),
    master_version INTEGER NOT NULL DEFAULT 1,
    child_version INTEGER NOT NULL DEFAULT 0,
    minor_version INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (version_key, master_version, child_version, minor_version)
);

-- 인덱스 추가 (성능 향상)
CREATE INDEX idx_versions_project_master ON versions(version_key, master_version);
CREATE INDEX idx_versions_project_master_child ON versions(version_key, master_version, child_version);

-- 에이전트 컨텐츠 테이블 생성
CREATE TABLE agent_contents (
    id UUID PRIMARY KEY,
    project_module_id UUID NOT NULL,
    contents TEXT,
    stage_type TEXT,
    order_num INTEGER,
    version TEXT,
    efct_st_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    efct_fns_dt TIMESTAMP DEFAULT '9999-12-31' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID
);

-- 인덱스 추가 (성능 최적화를 위해)
CREATE INDEX idx_agent_contents_project_module_id ON agent_contents(project_module_id);

-- 테이블에 코멘트 추가
COMMENT ON TABLE agent_contents IS 'AI 에이전트 콘텐츠 정보를 저장하는 테이블';
COMMENT ON COLUMN agent_contents.id IS '고유 식별자';
COMMENT ON COLUMN agent_contents.project_module_id IS '프로젝트 모듈 ID';
COMMENT ON COLUMN agent_contents.contents IS '콘텐츠 내용';
COMMENT ON COLUMN agent_contents.stage_type IS '단계 유형';
COMMENT ON COLUMN agent_contents.order_num IS '순서';
COMMENT ON COLUMN agent_contents.version IS '버전';
COMMENT ON COLUMN agent_contents.efct_st_dt IS '효력 시작 일시';
COMMENT ON COLUMN agent_contents.efct_fns_dt IS '효력 종료 일시';
COMMENT ON COLUMN agent_contents.created_at IS '생성 일시';
COMMENT ON COLUMN agent_contents.created_by IS '생성자';
COMMENT ON COLUMN agent_contents.updated_at IS '수정 일시';
COMMENT ON COLUMN agent_contents.updated_by IS '수정자';

-- 1. 다음 minor 버전을 구하는 함수
-- getVersion(project_id, master_version, child_version)
CREATE OR REPLACE FUNCTION getInternalVersion(p_version_key uuid, p_master_version INTEGER, p_child_version INTEGER)
RETURNS INTEGER AS $$
DECLARE
    next_minor INTEGER;
BEGIN
    -- 해당 master.child 버전의 최대 minor 버전 찾기
    SELECT COALESCE(MAX(minor_version), -1) + 1
    INTO next_minor
    FROM versions
    WHERE version_key = p_version_key
      AND master_version = p_master_version
      AND child_version = p_child_version;

    -- 새 버전 정보 삽입
    INSERT INTO versions (version_key, master_version, child_version, minor_version)
    VALUES (p_version_key, p_master_version, p_child_version, next_minor);

    RETURN next_minor;
END;
$$ LANGUAGE plpgsql;

-- 2. 다음 child 버전을 구하는 함수
CREATE OR REPLACE FUNCTION getInternalVersion(p_version_key uuid, p_master_version INTEGER)
RETURNS INTEGER AS $$
DECLARE
    next_child INTEGER;
BEGIN
    -- 해당 master 버전의 최대 child 버전 찾기
    SELECT COALESCE(MAX(child_version), -1) + 1
    INTO next_child
    FROM versions
    WHERE version_key = p_version_key
      AND master_version = p_master_version;

    -- 새 버전 정보 삽입 (minor_version은 0으로 시작)
    INSERT INTO versions (version_key, master_version, child_version, minor_version)
    VALUES (p_version_key, p_master_version, next_child, 0);

    RETURN next_child;
END;
$$ LANGUAGE plpgsql;

-- 3. 다음 master 버전을 구하는 함수
CREATE OR REPLACE FUNCTION getInternalVersion(p_version_key uuid)
RETURNS INTEGER AS $$
DECLARE
    next_master INTEGER;
BEGIN
    -- 해당 프로젝트의 최대 master 버전 찾기
    SELECT COALESCE(MAX(master_version), 0) + 1
    INTO next_master
    FROM versions
    WHERE version_key = p_version_key;

    -- 새 버전 정보 삽입 (child_version, minor_version은 0으로 시작)
    INSERT INTO versions (version_key, master_version, child_version, minor_version)
    VALUES (p_version_key, next_master, 0, 0);

    RETURN next_master;
END;
$$ LANGUAGE plpgsql;

-- 4. 통합 버전 처리 함수
CREATE OR REPLACE FUNCTION getVersion(p_version_key uuid, p_version_pattern TEXT)
RETURNS TEXT AS $$
DECLARE
    version_parts TEXT[];
    master_ver INTEGER;
    child_ver INTEGER;
    minor_ver INTEGER;
    result_version TEXT;
    plus_count INTEGER := 0;
    i INTEGER;
BEGIN
    -- '.'으로 분리하여 배열로 변환
    version_parts := string_to_array(p_version_pattern, '.');

    -- + 개수 카운트
    FOR i IN 1..array_length(version_parts, 1) LOOP
        IF version_parts[i] = '+' THEN
            plus_count := plus_count + 1;
        END IF;
    END LOOP;

    -- 패턴별 처리
    CASE array_length(version_parts, 1)
        -- 단일 레벨 (master 버전만)
        WHEN 1 THEN
            IF version_parts[1] = '?' THEN
                -- 현재 최대 master 버전 반환
                SELECT COALESCE(MAX(master_version), 0)
                INTO master_ver
                FROM versions
                WHERE version_key = p_version_key;
                result_version := master_ver::TEXT;

            ELSIF version_parts[1] = '+' THEN
                -- 다음 master 버전 생성
                master_ver := getInternalVersion(p_version_key);
                result_version := master_ver::TEXT;

            ELSIF version_parts[1] ~ '^[0-9]+$' THEN
                -- 특정 master 버전 반환
                result_version := version_parts[1];

            ELSE
                RAISE EXCEPTION '지원하지 않는 패턴입니다: %', version_parts[1];
            END IF;

        -- 두 레벨 (master.child)
        WHEN 2 THEN
            -- +.+ 패턴: 새 master와 새 child 생성
            IF version_parts[1] = '+' AND version_parts[2] = '+' THEN
                master_ver := getInternalVersion(p_version_key);
                child_ver := 0; -- 새 master의 첫 번째 child
                -- 새 master.child 레코드 생성
--                 INSERT INTO versions (version_key, master_version, child_version, minor_version)
--                 VALUES (p_version_key, master_ver, child_ver, 0);

            ELSE
                -- master 버전 처리
                IF version_parts[1] = '?' THEN
                    SELECT master_version INTO master_ver
                    FROM versions
                    WHERE version_key = p_version_key
                    ORDER BY master_version DESC, child_version DESC
                    LIMIT 1;
                    master_ver := COALESCE(master_ver, 0);
                ELSIF version_parts[1] ~ '^[0-9]+$' THEN
                    master_ver := version_parts[1]::INTEGER;
                ELSE
                    RAISE EXCEPTION '지원하지 않는 master 패턴입니다: %', version_parts[1];
                END IF;

                -- child 버전 처리
                IF version_parts[2] = '?' THEN
                    SELECT COALESCE(MAX(child_version), 0)
                    INTO child_ver
                    FROM versions
                    WHERE version_key = p_version_key AND master_version = master_ver;

                ELSIF version_parts[2] = '+' THEN
                    child_ver := getInternalVersion(p_version_key, master_ver);

                ELSIF version_parts[2] ~ '^[0-9]+$' THEN
                    child_ver := version_parts[2]::INTEGER;

                ELSE
                    RAISE EXCEPTION '지원하지 않는 child 패턴입니다: %', version_parts[2];
                END IF;
            END IF;

            result_version := master_ver::TEXT || '.' || child_ver::TEXT;

        -- 세 레벨 (master.child.minor)
        WHEN 3 THEN
            -- +.+.+ 패턴: 새 master, child, minor 모두 생성
            IF version_parts[1] = '+' AND version_parts[2] = '+' AND version_parts[3] = '+' THEN
                master_ver := getInternalVersion(p_version_key);
                child_ver := 0; -- 새 master의 첫 번째 child
                minor_ver := 0; -- 새 child의 첫 번째 minor
                -- 이미 getInternalVersion에서 레코드가 생성되므로 별도 INSERT 불필요

            ELSE
                -- master 버전 처리
                IF version_parts[1] = '?' THEN
                    SELECT master_version INTO master_ver
                    FROM versions
                    WHERE version_key = p_version_key
                    ORDER BY master_version DESC, child_version DESC, minor_version DESC
                    LIMIT 1;
                    master_ver := COALESCE(master_ver, 0);
                ELSIF version_parts[1] = '+' THEN
                    master_ver := getInternalVersion(p_version_key);
                ELSIF version_parts[1] ~ '^[0-9]+$' THEN
                    master_ver := version_parts[1]::INTEGER;
                ELSE
                    RAISE EXCEPTION '지원하지 않는 master 패턴입니다: %', version_parts[1];
                END IF;

                -- child 버전 처리
                IF version_parts[2] = '?' THEN
                    IF version_parts[1] = '?' THEN
                        -- 전체 최대에서 child 가져오기
                        SELECT child_version INTO child_ver
                        FROM versions
                        WHERE version_key = p_version_key
                        ORDER BY master_version DESC, child_version DESC, minor_version DESC
                        LIMIT 1;
                    ELSE
                        -- 특정 master의 최대 child
                        SELECT COALESCE(MAX(child_version), 0)
                        INTO child_ver
                        FROM versions
                        WHERE version_key = p_version_key AND master_version = master_ver;
                    END IF;
                ELSIF version_parts[2] = '+' THEN
                    child_ver := getInternalVersion(p_version_key, master_ver);
                ELSIF version_parts[2] ~ '^[0-9]+$' THEN
                    child_ver := version_parts[2]::INTEGER;
                ELSE
                    RAISE EXCEPTION '지원하지 않는 child 패턴입니다: %', version_parts[2];
                END IF;

                -- minor 버전 처리
                IF version_parts[3] = '?' THEN
                    IF version_parts[1] = '?' AND version_parts[2] = '?' THEN
                        -- 전체 최대에서 minor 가져오기
                        SELECT minor_version INTO minor_ver
                        FROM versions
                        WHERE version_key = p_version_key
                        ORDER BY master_version DESC, child_version DESC, minor_version DESC
                        LIMIT 1;
                    ELSE
                        -- 특정 master.child의 최대 minor
                        SELECT COALESCE(MAX(minor_version), 0)
                        INTO minor_ver
                        FROM versions
                        WHERE version_key = p_version_key
                          AND master_version = master_ver
                          AND child_version = child_ver;
                    END IF;
                ELSIF version_parts[3] = '+' THEN
                    minor_ver := getInternalVersion(p_version_key, master_ver, child_ver);
                ELSIF version_parts[3] ~ '^[0-9]+$' THEN
                    minor_ver := version_parts[3]::INTEGER;
                ELSE
                    RAISE EXCEPTION '지원하지 않는 minor 패턴입니다: %', version_parts[3];
                END IF;
            END IF;

            minor_ver := COALESCE(minor_ver, 0);
            result_version := master_ver::TEXT || '.' || child_ver::TEXT || '.' || minor_ver::TEXT;

        ELSE
            RAISE EXCEPTION '지원하지 않는 버전 레벨입니다. 1-3 레벨만 지원합니다.';
    END CASE;

    RETURN result_version;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------------------
-- 여기서 부터는 DML
------------------------------------------------------------------------------------
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('97924c6e-fb97-48e3-93cb-62c993ae12c9', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '40897068-37e2-4a49-9d81-71afa374d466', '2025-06-25 05:41:03.143149 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-25 05:41:03.143149 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('3222c7f9-eb69-4edd-83cf-2e70c196f5ab', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', 'ab45fefd-98d7-4f21-b7d8-7b8576df447c', '2025-06-25 05:52:49.386584 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-25 05:52:49.386588 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('0d6d9ca0-425f-4301-ab37-cbffb6c264e0', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', 'c49bd031-2b00-4aa3-9889-e3afa5ab4a6b', '2025-07-03 09:36:54.621774 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-03 09:36:54.621774 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('4d057018-fe4d-4115-be33-9bc31cfcb392', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '7f538c3a-f126-4e47-be81-43ab0f114fa7', '2025-07-04 06:32:40.076566 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-04 06:32:40.076571 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('12f971df-3f5f-40be-990b-a31926ea2742', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', 'f2e973bb-3098-4b8c-8b51-61b1f86364fd', '2025-07-07 00:51:03.123185 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 00:51:03.123191 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('15829083-e225-45da-8c19-45cfe7fad9f2', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '554fad6f-e418-4556-ae94-7d0ac17927e0', '2025-07-07 02:11:37.760219 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 02:11:37.760223 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('1a39df14-51b8-4cff-be0c-2747df8c4aa0', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '7935808c-350d-4702-96b0-01860ddd5c3b', '2025-07-07 02:21:24.345616 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 02:21:24.345620 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('7d55ac7d-f150-4087-aa5e-b62b7a4b2f2c', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '04e9bd12-6005-4f10-aa38-de831bb7065c', '2025-07-07 07:52:37.008716 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 07:52:37.008719 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('96e92522-c0e5-49cc-bc37-092b5570b5e8', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', 'eee74e16-885a-40a7-b357-fc68fe9e1dc0', '2025-07-08 23:06:03.720681 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-08 23:06:03.720685 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('a145b506-e8d9-4f62-bcf7-9e210c359dff', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '875da244-28e1-44e8-b878-3b1a60215555', '2025-07-09 00:16:19.432493 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:16:19.432503 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('438dc1ce-b21c-47f1-bab1-d6cedd578e7f', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '6e867338-c7e3-4199-b541-cd0387c0d276', '2025-07-09 00:27:18.016622 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:18.016634 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('8a75bb2f-4cbd-454b-92b5-8970fad8ac22', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '05ded472-d1c7-467b-906c-a774003ec54e', '2025-07-09 00:27:30.276244 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:30.276247 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('5a1ddec0-974a-4262-bf5e-923815a26e66', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '4b60b875-02c6-444d-a639-0e41160945bb', '2025-07-09 01:50:25.671659 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:50:25.671666 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('af96f5a0-614e-42af-9c0b-9169b2c22267', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', 'ee16f91e-322c-4139-8d8c-f05c480faa63', '2025-07-09 04:35:40.687217 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:35:40.687222 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('42db6a11-9521-4321-8b7f-a23391f223d1', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '02fdfd95-7e30-4f34-8241-c6989fdbd4ec', '2025-07-09 05:32:39.398827 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:32:39.398831 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('46cee941-e867-48bb-94ca-40971e846b0f', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '5e4f1ade-9f90-4025-add3-47967a9f2c74', '2025-07-09 07:45:25.135182 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:45:25.135190 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.tenant_project_joins (id, tenant_id, project_id, created_at, created_by, updated_at, updated_by) VALUES ('02b1a45a-3f9a-432e-99ab-ea923da8946b', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', '2025-07-09 07:45:38.204765 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:45:38.204768 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');

INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('ab45fefd-98d7-4f21-b7d8-7b8576df447c', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '프로젝트/조인 생성 테스트', '프로젝트/조인 생성 테스트', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-25 05:52:49.381781 +00:00', '2025-06-25 06:28:54.737400 +00:00', '2025-06-25 05:52:49.383327 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-25 06:28:54.738111 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('c49bd031-2b00-4aa3-9889-e3afa5ab4a6b', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', 'test', 'test', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-03 18:36:00.000000 +00:00', '2025-07-31 18:36:00.000000 +00:00', '2025-07-03 09:36:54.605343 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-03 09:36:54.605343 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('40897068-37e2-4a49-9d81-71afa374d466', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '123', '123', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-25 05:41:21.683783 +00:00', '2025-07-07 00:50:38.578920 +00:00', '2025-06-25 05:41:21.683783 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 00:50:46.608480 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('f2e973bb-3098-4b8c-8b51-61b1f86364fd', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '1123', '1123', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 00:51:03.116785 +00:00', '2025-07-07 00:51:23.415038 +00:00', '2025-07-07 00:51:03.118659 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 00:51:23.415344 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('7f538c3a-f126-4e47-be81-43ab0f114fa7', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '프로젝트 222', '프로젝트 2222', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-04 06:32:40.071986 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-04 06:32:40.073547 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 01:27:43.928295 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('554fad6f-e418-4556-ae94-7d0ac17927e0', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', 'test1111', 'test description 1111', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 02:11:37.755311 +00:00', '2025-07-07 02:14:42.389038 +00:00', '2025-07-07 02:11:37.756659 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 02:14:42.389574 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('7935808c-350d-4702-96b0-01860ddd5c3b', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', 'project 333333', 'project description 3333333', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 02:21:24.342141 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-07 02:21:24.342677 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 02:21:24.342681 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('04e9bd12-6005-4f10-aa38-de831bb7065c', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '프로젝트 123', '프로젝트 123', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 07:52:37.002719 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-07 07:52:37.004347 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-07 07:52:37.004353 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('eee74e16-885a-40a7-b357-fc68fe9e1dc0', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '김효연_개발 테스트 - 250709', '김효연_개발 테스트 - 250709', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-08 23:06:03.716345 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-08 23:06:03.717915 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-08 23:06:03.717920 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('875da244-28e1-44e8-b878-3b1a60215555', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '김효연_개발 테스트 - 250709', '김효연_개발 테스트 - 250709', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:16:19.412004 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-09 00:16:19.414781 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:16:19.414809 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('6e867338-c7e3-4199-b541-cd0387c0d276', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '김효연_개발 테스트 - 250709', '김효연_개발 테스트 - 250709', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:18.003987 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-09 00:27:18.005258 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:18.005264 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('05ded472-d1c7-467b-906c-a774003ec54e', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '프로젝트/조인 생성 테스트 - 20250709', '프로젝트/조인 생성 테스트 - 20250709', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:30.272630 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-09 00:27:30.273830 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:30.273835 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('4b60b875-02c6-444d-a639-0e41160945bb', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '프로젝트/조인 생성 테스트 - 250709', '프로젝트/조인 생성 테스트 - 250709', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:50:25.614325 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-09 01:50:25.618294 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:50:25.618300 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('ee16f91e-322c-4139-8d8c-f05c480faa63', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '프로젝트/조인 생성 테스트 - 250708', '프로젝트/조인 생성 테스트 - 250708', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:35:40.657837 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-09 04:35:40.658608 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:35:40.658612 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('02fdfd95-7e30-4f34-8241-c6989fdbd4ec', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '김효연_개발 테스트 - 250709', '김효연_개발 테스트 - 250709', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:32:39.392494 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-09 05:32:39.393701 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:32:39.393706 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('5e4f1ade-9f90-4025-add3-47967a9f2c74', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '프로젝트/조인 생성 테스트 - 250708', '프로젝트/조인 생성 테스트 - 250708', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:45:25.109723 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-09 07:45:25.112741 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:45:25.112749 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');
INSERT INTO public.projects (id, tenant_id, name, description, owner, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, information) VALUES ('4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'aaf7ddd6-6b6d-467d-bacf-e238e314e737', '프로젝트/조인 생성 테스트 - hwadong', '프로젝트/조인 생성 테스트 - hwadong', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:45:38.167135 +00:00', '9999-12-31 00:00:00.000000 +00:00', '2025-07-09 07:45:38.167316 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:45:38.167318 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '{}');

INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('123e4567-e89b-12d3-a456-426614174000', '40897068-37e2-4a49-9d81-71afa374d466', 'code-analyzer', 'implement_agents','success', 100, '2025-06-25 05:44:41.460919', '9999-12-31 00:00:00.000000', '2025-06-25 05:44:41.460919 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-25 05:44:41.460919 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('c523f4aa-cb6c-4430-953d-862a6ba6239a', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 04:59:47.206314', '9999-12-31 00:00:00.000000', '2025-07-09 04:59:47.220077 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:59:49.085129 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('14eedfb2-6d93-4735-a5f5-d2b74300dc60', '4b60b875-02c6-444d-a639-0e41160945bb', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 02:08:07.931490', '9999-12-31 00:00:00.000000', '2025-07-09 02:08:07.988075 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:08:11.292778 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('f4279e1f-ab7c-47ef-b6bc-0383f728c5bc', 'ab45fefd-98d7-4f21-b7d8-7b8576df447c', 'code-analyzer', 'implement_agents', 'processing', 64, '2025-06-30 12:55:23.433000', '9999-12-31 00:00:00.000000', '2025-07-01 01:12:33.460000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-01 01:12:33.460000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('7a4a2b61-4696-4f0f-812c-e41fa607cc3f', '4b60b875-02c6-444d-a639-0e41160945bb', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 02:09:42.849177', '9999-12-31 00:00:00.000000', '2025-07-09 02:09:42.872628 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:12:44.029546 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('773ede5a-1c88-472c-98e7-53a5923d2c27', 'ab45fefd-98d7-4f21-b7d8-7b8576df447c', 'code-analyzer', 'implement_agents', 'success', 100, '2025-06-30 11:34:32.430000', '2025-06-30 12:55:23.433000', '2025-06-30 02:34:32.430000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-30 03:55:23.433000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('4fd47f3d-b110-4e81-bb73-131ec68c276b', 'ab45fefd-98d7-4f21-b7d8-7b8576df447c', 'code-analyzer', 'implement_agents', 'success', 100, '2025-06-30 10:12:33.460000', '2025-07-01 11:34:32.430000', '2025-06-30 01:12:33.460000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-01 02:34:32.430000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('2e6ff76b-3849-4288-808f-9c8d75a44922', 'ab45fefd-98d7-4f21-b7d8-7b8576df447c', 'code-analyzer', 'implement_agents', 'failed', 100, '2025-06-30 10:55:23.230000', '2025-06-30 10:55:23.230000', '2025-06-30 01:55:23.230000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-30 01:55:23.230000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('8c5994b8-0f7e-4ca6-a740-26a8f1710170', 'ab45fefd-98d7-4f21-b7d8-7b8576df447c', 'code-analyzer', 'implement_agents', 'waiting', 100, '2025-06-30 12:59:23.433000', '9999-12-31 00:00:00.000000', '2025-06-30 03:59:23.433000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-06-30 03:59:23.433000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('d7d9c895-661b-4bc9-af3d-334100622729', '01fd482d-1ff7-400b-8cb4-fe15e4dfff2b', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-02 05:53:12.086858', '9999-12-31 00:00:00.000000', '2025-07-02 05:53:12.088843 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-02 05:53:12.088851 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('1a17037f-755d-4c9e-9117-70a41fcef86e', 'baad61a0-566e-4a72-ae22-8e52366460dc', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 00:11:03.771186', '9999-12-31 00:00:00.000000', '2025-07-09 00:11:03.787372 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:11:03.787376 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('acbd9fe3-0ae8-4418-9dd3-f4d6af96f8bf', '875da244-28e1-44e8-b878-3b1a60215555', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 00:17:09.317060', '9999-12-31 00:00:00.000000', '2025-07-09 00:17:09.336749 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:17:09.336755 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('ce697eeb-72ab-4755-9f84-3e3f093f4ead', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 00:27:24.953841', '9999-12-31 00:00:00.000000', '2025-07-09 00:27:24.968873 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:43.619122 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('2de87de2-add1-48d0-be38-b02d48112d0e', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 00:29:22.272665', '9999-12-31 00:00:00.000000', '2025-07-09 00:29:22.291069 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:29:22.291072 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('5c658a2f-b899-47ed-b804-479c04814b12', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 00:42:15.432747', '9999-12-31 00:00:00.000000', '2025-07-09 00:42:15.452942 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:42:15.452960 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('2abc3895-845d-4c89-b023-42bd4f5ed766', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 00:44:16.251211', '9999-12-31 00:00:00.000000', '2025-07-09 00:44:16.268747 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:44:16.268750 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('66969837-86ca-4300-9fcc-d67112efd9ed', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 00:49:03.844631', '9999-12-31 00:00:00.000000', '2025-07-09 00:49:03.875430 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:49:03.875433 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('108c4a59-9c50-4118-b623-fe60dd95ba57', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 00:57:07.733309', '9999-12-31 00:00:00.000000', '2025-07-09 00:57:07.750243 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:57:07.750258 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('9faba94f-e9fd-480d-b2d0-c82a6e61a787', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 00:57:09.954228', '9999-12-31 00:00:00.000000', '2025-07-09 00:57:09.969420 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:57:09.969430 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('b6c2b8f6-921a-4df3-8d65-3ed042173e8f', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 01:52:46.604413', '9999-12-31 00:00:00.000000', '2025-07-09 01:52:46.643068 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:52:46.643075 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('5812d9eb-a4ba-449a-9eb1-442fdb05bbb1', '4b60b875-02c6-444d-a639-0e41160945bb', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 01:51:23.880380', '9999-12-31 00:00:00.000000', '2025-07-09 01:51:23.897175 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:57:07.634943 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('62739b05-dfc9-4c29-8170-da00b5385018', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 01:57:48.368566', '9999-12-31 00:00:00.000000', '2025-07-09 01:57:48.399301 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:57:48.399307 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('007f4ca4-0720-433a-864b-ff383eaea8f9', '6e867338-c7e3-4199-b541-cd0387c0d276', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 01:58:44.399173', '9999-12-31 00:00:00.000000', '2025-07-09 01:58:44.417105 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:58:44.417112 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('ebc2d461-d705-4dba-a033-0094757e97f8', '4b60b875-02c6-444d-a639-0e41160945bb', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 02:00:09.704533', '9999-12-31 00:00:00.000000', '2025-07-09 02:00:09.714066 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:00:14.130055 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('c6d132e1-0257-427e-af8c-7d129c3dafe1', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 04:45:51.894699', '9999-12-31 00:00:00.000000', '2025-07-09 04:45:51.921237 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:45:56.086881 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('21b39cbe-4687-4d74-8c43-a1584f781613', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:01:36.685164', '9999-12-31 00:00:00.000000', '2025-07-09 05:01:36.701022 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:01:41.391629 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('702af4e1-e464-461e-8637-baea0515ba00', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 04:48:48.038611', '9999-12-31 00:00:00.000000', '2025-07-09 04:48:48.047393 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:48:50.824948 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('bb7fb889-3f57-4a28-b0ba-2137b30e7207', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 04:49:01.569905', '9999-12-31 00:00:00.000000', '2025-07-09 04:49:01.592690 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:49:03.923691 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('bc6cfa11-7235-4502-9e6c-429b2c60543b', '02fdfd95-7e30-4f34-8241-c6989fdbd4ec', 'code-analyzer', 'implement_agents', 'processing', 0, '2025-07-09 05:32:45.399728', '9999-12-31 00:00:00.000000', '2025-07-09 05:32:45.403464 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:32:45.549292 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('bc986368-5666-459d-b04e-0bd252f5f2b0', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 04:56:45.699415', '9999-12-31 00:00:00.000000', '2025-07-09 04:56:45.715607 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:56:47.989253 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('9fd0e0fb-2fb6-449c-ba76-e8628609b0dd', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:01:56.249933', '9999-12-31 00:00:00.000000', '2025-07-09 05:01:56.265466 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:02:00.596849 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('93a1d387-fa8b-4796-ae72-a7aa7fc0e359', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:41:50.928061', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:50.948535 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:52.798610 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('16cd124e-2416-446a-a67c-a58bc469756c', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:12:19.669539', '9999-12-31 00:00:00.000000', '2025-07-09 05:12:19.683266 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:22.125926 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('fe6a6038-3d77-4bb8-8f81-72e0f72e79ed', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:33:32.886974', '9999-12-31 00:00:00.000000', '2025-07-09 05:33:32.969109 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:33:41.368759 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('4c6ad618-8c66-419a-a2b8-c063ed34f288', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:12:40.214034', '9999-12-31 00:00:00.000000', '2025-07-09 05:12:40.226512 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:42.169495 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('d4b664e5-2dc2-4edd-84af-338de6c1acee', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:12:48.942623', '9999-12-31 00:00:00.000000', '2025-07-09 05:12:48.961085 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:51.151705 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('50aa2618-bcf1-4373-8df4-0536e3d58357', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 05:12:56.934002', '9999-12-31 00:00:00.000000', '2025-07-09 05:12:56.947201 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:56.947205 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('367fecf6-3d3d-412d-aa5a-efb70c607b45', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 05:18:04.527946', '9999-12-31 00:00:00.000000', '2025-07-09 05:18:04.543090 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:18:04.543095 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('8abc6f34-0059-4d7f-ac16-9264265c6658', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 05:28:20.529271', '9999-12-31 00:00:00.000000', '2025-07-09 05:28:20.543289 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:28:20.543293 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('9622ee3a-6cca-47e5-91f0-9fce08592583', '02fdfd95-7e30-4f34-8241-c6989fdbd4ec', 'code-analyzer', 'implement_agents', 'processing', 0, '2025-07-09 05:33:46.860453', '9999-12-31 00:00:00.000000', '2025-07-09 05:33:46.862551 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:33:47.000512 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('f0a30beb-a8f8-4539-b72b-4039ecb4060a', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 05:34:32.707166', '9999-12-31 00:00:00.000000', '2025-07-09 05:34:32.716620 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:34:32.716623 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('0d895df9-5ae1-4d71-89c0-3a48bfd0b201', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'processing', 0, '2025-07-09 05:41:27.249149', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:27.258356 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:28.238885 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('2577d404-7bea-4301-a23b-45b96d082873', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:41:37.658760', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:37.667734 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:40.329632 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('a208eca5-12da-45dd-82ea-e1d210aa967a', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:41:33.350807', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:33.374230 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:35.454060 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('652939b1-121d-47a9-b265-a0977abf05ec', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:41:46.142312', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:46.152396 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:48.034331 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('76e81454-8180-42d4-a9a5-05cde9d906e8', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 05:41:42.000739', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:42.009771 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:43.829840 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('5b7ccbb9-a810-44cd-b98f-d46c8dd917ff', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:07:19.354292', '9999-12-31 00:00:00.000000', '2025-07-09 07:07:19.372339 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:07:19.372343 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('9f1b404d-159c-4162-8204-0e8befe01512', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 06:18:46.585858', '9999-12-31 00:00:00.000000', '2025-07-09 06:18:46.601613 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:49.164373 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('71e4f0c0-4288-4291-bbb8-e20afbed2728', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 06:18:52.070616', '9999-12-31 00:00:00.000000', '2025-07-09 06:18:52.087933 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:54.188926 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('9a2a7de2-65f4-4c26-88f0-3fbb0ac09300', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 06:18:56.321092', '9999-12-31 00:00:00.000000', '2025-07-09 06:18:56.330665 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:58.358659 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('ae7a44cc-51cc-439f-9b9e-dd4066b4c392', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:03:17.187673', '9999-12-31 00:00:00.000000', '2025-07-09 07:03:17.232613 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:03:17.232617 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('232864f9-9660-4e8c-9865-972557bf6246', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:12:04.305336', '9999-12-31 00:00:00.000000', '2025-07-09 07:12:04.315787 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:12:04.315789 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('5b4eb951-fe9b-4285-946a-ba920ecd5dff', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:12:46.592195', '9999-12-31 00:00:00.000000', '2025-07-09 07:12:46.602959 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:12:46.602963 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('7b2b0560-2a27-4611-9457-a6ec12382d5c', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:13:31.401565', '9999-12-31 00:00:00.000000', '2025-07-09 07:13:31.420745 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:13:31.420748 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('7612d77d-c22f-40c9-a46d-174d6a618513', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:16:22.858764', '9999-12-31 00:00:00.000000', '2025-07-09 07:16:22.890303 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:16:22.890307 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('9ab572ad-ac6c-4efb-8a81-c4361690a275', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:20:01.838754', '9999-12-31 00:00:00.000000', '2025-07-09 07:20:01.862617 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:20:01.862622 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('75b35088-b794-4be4-bf5e-84cb07150d7d', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:21:30.405247', '9999-12-31 00:00:00.000000', '2025-07-09 07:21:30.472176 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:21:30.472179 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('9d94cfb9-d50f-45ec-bb19-9e0e70a349b6', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:24:17.083693', '9999-12-31 00:00:00.000000', '2025-07-09 07:24:17.108041 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:24:17.108044 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('53129355-2428-4d5a-ab78-f47c9494a9d8', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:26:15.124385', '9999-12-31 00:00:00.000000', '2025-07-09 07:26:15.135062 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:26:15.135066 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('f8a55e29-67f8-4533-bdee-0c01403b44a5', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:28:28.375862', '9999-12-31 00:00:00.000000', '2025-07-09 07:28:28.411896 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:28:28.411900 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('aa93573d-c125-4b3e-846d-bc008c6a40c4', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:29:52.940862', '9999-12-31 00:00:00.000000', '2025-07-09 07:29:52.956785 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:29:52.956795 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('7c1030a1-6c90-46fc-9ea9-e0034362f9d2', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:30:03.634362', '9999-12-31 00:00:00.000000', '2025-07-09 07:30:03.648198 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:30:03.648202 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('02ed01de-4529-4e3e-8209-d566d30ba279', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:32:03.003626', '9999-12-31 00:00:00.000000', '2025-07-09 07:32:03.029706 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:32:03.029711 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('e8739518-f54b-4c6f-8700-04e2767774da', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'waiting', 0, '2025-07-09 07:32:31.136205', '9999-12-31 00:00:00.000000', '2025-07-09 07:32:31.149185 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:32:31.149189 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('7e3b5663-c8e4-4545-a4f6-b146f7643fca', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 07:35:15.082593', '9999-12-31 00:00:00.000000', '2025-07-09 07:35:15.163285 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:35:19.737709 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('9e7a1a2e-1639-4022-86b7-740c76c67c6c', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 07:49:50.604505', '9999-12-31 00:00:00.000000', '2025-07-09 07:49:50.608033 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:49:52.886870 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('2841a517-809f-44fa-b0ea-1520e5246905', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 07:50:40.136455', '9999-12-31 00:00:00.000000', '2025-07-09 07:50:40.139891 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:50:42.220335 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('b5c9b23d-5226-4f53-ad87-593f92185bd6', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 07:51:19.601554', '9999-12-31 00:00:00.000000', '2025-07-09 07:51:19.603993 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:51:21.507363 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');
INSERT INTO public.project_modules (id, project_id, module_type, parent_module_type, status, progress, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, version) VALUES ('cdc8fd36-e23f-4bc6-9498-bbf948d4ae87', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'code-analyzer', 'implement_agents', 'success', 100, '2025-07-09 07:52:22.892209', '9999-12-31 00:00:00.000000', '2025-07-09 07:52:22.893801 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:52:27.769479 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60','1.0.0');

INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('d691acf7-f69b-403e-910c-0ec90be93aaa', 'd7d9c895-661b-4bc9-af3d-334100622729', '3c3e99d8-67f1-408b-9c9d-3a0d27801bfd', '2025-07-02 05:53:12.114413 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-02 05:53:12.114426 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('6c575be2-773d-4914-84ed-e7960cc33a4e', '1a17037f-755d-4c9e-9117-70a41fcef86e', '7ac309a2-ca10-4609-ad39-94063a6b6918', '2025-07-09 00:11:03.806593 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:11:03.806598 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('d809f09f-f67f-4ed3-b1cc-c9475842e00e', 'acbd9fe3-0ae8-4418-9dd3-f4d6af96f8bf', 'a06b34c6-f231-4a6a-9e1f-e1260c071a66', '2025-07-09 00:17:09.355261 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:17:09.355269 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('617fe67d-065e-44b8-8815-b810d249fbe5', 'ce697eeb-72ab-4755-9f84-3e3f093f4ead', '7a87d96d-e2b6-4ee6-a9ab-ff7cebee0a4c', '2025-07-09 00:27:24.986981 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:24.986984 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('7d267258-6aa2-416b-b4d8-e243963241a4', '2de87de2-add1-48d0-be38-b02d48112d0e', '63277c23-ddbb-412d-a865-70bae5e043da', '2025-07-09 00:29:22.308887 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:29:22.308890 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('f4751aec-9df2-4bb3-bc1d-4401870755b4', '5c658a2f-b899-47ed-b804-479c04814b12', 'b0df11e0-80dd-4804-b8ec-60c0422bf2fc', '2025-07-09 00:42:15.473343 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:42:15.473350 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('0eb45dc4-1e05-4c21-b105-de392d05bc19', '2abc3895-845d-4c89-b023-42bd4f5ed766', '69862013-560d-46e4-aede-57c262816b6f', '2025-07-09 00:44:16.288120 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:44:16.288122 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('21b2f454-a1f1-4e5f-a635-ef63a16b72ed', '66969837-86ca-4300-9fcc-d67112efd9ed', 'd432ebe0-33ba-4a09-92ea-52a5c21bb40b', '2025-07-09 00:49:03.894004 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:49:03.894008 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('4833c2f1-ffc2-4c9d-a1e8-a77910062fa1', '108c4a59-9c50-4118-b623-fe60dd95ba57', '99abd4bc-6002-453f-88a1-6179c7bc8b88', '2025-07-09 00:57:07.769107 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:57:07.769115 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('37442816-bcb9-46bd-9116-010ab75926d4', '9faba94f-e9fd-480d-b2d0-c82a6e61a787', '7a2894f3-b1dc-4789-8d70-860aed1b1d47', '2025-07-09 00:57:09.985628 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:57:09.985641 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('1ea8c95b-0d7c-436f-875f-e409a78fd332', '5812d9eb-a4ba-449a-9eb1-442fdb05bbb1', 'd5380be3-01ad-43ee-b758-030a2216c5c2', '2025-07-09 01:51:23.939168 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:51:23.939173 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('a478a453-ef34-4653-8bc2-87f86e0725d7', 'b6c2b8f6-921a-4df3-8d65-3ed042173e8f', '07a1a065-9a6f-4d92-bee9-7273d5d41400', '2025-07-09 01:52:46.691137 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:52:46.691151 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('93c79b72-e45f-4a9c-8f2a-5b69d781f648', '62739b05-dfc9-4c29-8170-da00b5385018', '4fda53a9-baf5-48cd-a1d4-c13da461c592', '2025-07-09 01:57:48.425469 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:57:48.425476 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('f7a02dbf-87e1-43a2-a534-bce629b89fc6', '007f4ca4-0720-433a-864b-ff383eaea8f9', 'bb0a572e-c352-4c26-a209-24f017f103de', '2025-07-09 01:58:44.439124 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:58:44.439142 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('c5c95f4c-04a1-4135-92ef-092fc2c5cb5a', 'ebc2d461-d705-4dba-a033-0094757e97f8', 'f25addbb-84ff-49f9-ac9e-1f753d685322', '2025-07-09 02:00:09.759674 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:00:09.759678 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('41ca8fda-5d56-49f0-98ff-20a51f606534', '14eedfb2-6d93-4735-a5f5-d2b74300dc60', '898ded99-afac-4ec1-b818-726ed9edce33', '2025-07-09 02:08:08.029602 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:08:08.029613 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('f6d522ea-cd99-408d-9e55-8769fd698561', '7a4a2b61-4696-4f0f-812c-e41fa607cc3f', '2900afb1-ff10-4cb1-9bca-a6ab11bfeeec', '2025-07-09 02:09:42.949541 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:09:42.949545 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('7a3d684f-5cb6-4147-9701-02cf2ac5c053', 'c6d132e1-0257-427e-af8c-7d129c3dafe1', '5ac1a4fe-812a-4079-b6fe-0b35fd2816c8', '2025-07-09 04:45:51.974980 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:45:51.974983 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('43e29fb7-17a3-42db-8fce-5f5196906051', '702af4e1-e464-461e-8637-baea0515ba00', '6cc1cd1d-9518-49a0-b9ff-7481beb4483f', '2025-07-09 04:48:48.081852 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:48:48.081855 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('140448d0-1155-4c0c-a4f3-a993d2279cc7', 'bb7fb889-3f57-4a28-b0ba-2137b30e7207', '2ddb99b7-a8f7-4c72-8a44-2d367e88bf0b', '2025-07-09 04:49:01.649155 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:49:01.649167 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('09e7e434-c992-443b-8151-1922c4a42823', 'bc986368-5666-459d-b04e-0bd252f5f2b0', 'a2bc3d62-deb8-44e7-b9de-12afce4ea134', '2025-07-09 04:56:45.754420 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:56:45.754426 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('27c8771a-6968-4177-8139-80b64ddd9735', 'c523f4aa-cb6c-4430-953d-862a6ba6239a', '38bb9db5-d94a-413d-9e4c-bd9848f67e38', '2025-07-09 04:59:47.259687 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:59:47.259688 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('b1d2ce17-7c49-4d53-b95e-3dd2f82ea40c', '21b39cbe-4687-4d74-8c43-a1584f781613', 'a97e573b-3001-40db-8d09-e276368e1e96', '2025-07-09 05:01:36.732876 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:01:36.732881 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('c6594db9-3635-4538-b669-922743afac45', '9fd0e0fb-2fb6-449c-ba76-e8628609b0dd', '86a7e7fc-9b56-4a35-b93a-c10a9e5fbec1', '2025-07-09 05:01:56.290817 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:01:56.290820 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('1d59c243-26d5-4b25-ab08-3378b2139cd3', '16cd124e-2416-446a-a67c-a58bc469756c', 'c3c11233-45d3-4cc3-bd75-679a27682ea7', '2025-07-09 05:12:19.766491 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:19.766496 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('e6435150-88be-4faf-be1d-cb24ddfed812', '4c6ad618-8c66-419a-a2b8-c063ed34f288', '7b7868e0-9ed7-4c6b-bb66-33ea8cb63387', '2025-07-09 05:12:40.344674 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:40.344677 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('16ed43d2-2cd6-40dc-9b00-1f144e3104c6', 'd4b664e5-2dc2-4edd-84af-338de6c1acee', '05de7bfc-d6a5-4c0f-a6dc-3926feef32a6', '2025-07-09 05:12:49.068431 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:49.068436 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('c1f6a2f2-0b38-4243-a360-d343792bde85', 'bc6cfa11-7235-4502-9e6c-429b2c60543b', 'a873cbb6-3d2c-4415-98fc-8ecdf69a5cf3', '2025-07-09 05:32:45.412000 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:32:45.412006 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('7d1c79fe-82f9-4fa3-858f-51cf496a9ad0', 'fe6a6038-3d77-4bb8-8f81-72e0f72e79ed', '09453092-bd5a-452d-8333-f3acdbac54ee', '2025-07-09 05:33:33.385167 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:33:33.385170 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('287eb7d7-30fd-41f0-8bde-9e242853106d', '9622ee3a-6cca-47e5-91f0-9fce08592583', '0c039935-9b73-4324-a84e-610f39b3095a', '2025-07-09 05:33:46.868405 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:33:46.868409 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('082a3241-f77b-431a-b9d4-598833a2b67a', '0d895df9-5ae1-4d71-89c0-3a48bfd0b201', '61466cc9-3ad4-469d-bc45-4a59db7d3e20', '2025-07-09 05:41:27.304396 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:27.304401 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('39628eb5-cb89-4841-9ed4-3b6e1e3606f8', 'a208eca5-12da-45dd-82ea-e1d210aa967a', 'c7c9f088-7f05-4918-b056-6298e6c59168', '2025-07-09 05:41:33.416468 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:33.416472 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('1fcd1aa8-46be-46e5-9580-230f85fccf68', '2577d404-7bea-4301-a23b-45b96d082873', '9eab4d66-15eb-4286-90ff-dde43c9bafb0', '2025-07-09 05:41:37.968458 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:37.968461 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('a3c7963e-a610-4e1c-83ec-bcf14fc16338', '76e81454-8180-42d4-a9a5-05cde9d906e8', 'b3413e6c-81fb-4241-a9aa-90cf1f4eaa60', '2025-07-09 05:41:42.045965 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:42.045968 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('5dc59061-cee7-4693-9631-6438aad6b97b', '652939b1-121d-47a9-b265-a0977abf05ec', 'b7252847-af48-4e76-8ff0-35816d8c645f', '2025-07-09 05:41:46.183915 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:46.183918 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('cbb95f1c-d65f-4058-9c31-d19e45f53810', '93a1d387-fa8b-4796-ae72-a7aa7fc0e359', '2075f4e1-3a07-44cf-8d49-8d18dc371825', '2025-07-09 05:41:50.979310 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:50.979312 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('5f392eac-3d56-44a0-9d2f-f658f896355e', '9f1b404d-159c-4162-8204-0e8befe01512', '633a87fc-68a1-44cd-9b4b-a555c5aea03d', '2025-07-09 06:18:46.642142 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:46.642151 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('8ccff4a1-d953-401f-94b0-b33909376070', '71e4f0c0-4288-4291-bbb8-e20afbed2728', 'f099a262-22d6-41fd-946b-242394ca35b7', '2025-07-09 06:18:52.135824 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:52.135835 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('de3d5060-4fe7-4930-95fc-a768c3d294ed', '9a2a7de2-65f4-4c26-88f0-3fbb0ac09300', 'e3c90284-9b85-40d7-ab57-db0dcd3ff2b5', '2025-07-09 06:18:56.356024 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:56.356027 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('b3816df2-b015-4065-9309-be118f88e587', 'ae7a44cc-51cc-439f-9b9e-dd4066b4c392', '5f9158d9-58e3-4354-a8d6-b8be08857249', '2025-07-09 07:03:17.265822 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:03:17.265826 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('04986971-a0f6-4011-ade2-328c97ba8f59', '5b7ccbb9-a810-44cd-b98f-d46c8dd917ff', 'c7fb3d09-03a2-4f7f-96b4-de7c17f08d5d', '2025-07-09 07:07:19.401692 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:07:19.401696 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('b1d7da53-f081-45a4-9cec-77c272e89def', '232864f9-9660-4e8c-9865-972557bf6246', '52fd4e5b-c8a5-4bdd-95d2-472abc18b628', '2025-07-09 07:12:04.380625 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:12:04.380631 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('aa158deb-476f-479f-bb1f-fa544d33d45c', '5b4eb951-fe9b-4285-946a-ba920ecd5dff', '7b1f2c67-4715-48be-abd1-117fefedc8a3', '2025-07-09 07:12:46.636003 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:12:46.636009 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('c5b62566-1826-4ed7-8717-583f030cd8c7', '7b2b0560-2a27-4611-9457-a6ec12382d5c', 'f7c85542-3cc0-4b25-a493-81e444bd3122', '2025-07-09 07:13:31.626649 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:13:31.626652 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('8254bc05-5997-4716-8d7f-5a2aab3c0481', '7612d77d-c22f-40c9-a46d-174d6a618513', 'bdecf1f3-28d3-4a54-9306-1efa904e3a88', '2025-07-09 07:16:22.956562 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:16:22.956572 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('319119bc-403a-48ca-aef5-42f284b55b5a', '9ab572ad-ac6c-4efb-8a81-c4361690a275', 'f0fcd0d4-dc9b-404b-98b2-5919e4eb2681', '2025-07-09 07:20:01.920520 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:20:01.920529 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('f9bc83a3-c9ea-4979-93b0-7b680656d942', '75b35088-b794-4be4-bf5e-84cb07150d7d', '459c04bf-617c-479b-aa28-edc94ad0d17c', '2025-07-09 07:21:30.931178 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:21:30.931181 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('df38f201-dd6b-4e28-a02f-41fb8279d27b', '9d94cfb9-d50f-45ec-bb19-9e0e70a349b6', '9e7312d2-54b2-43f3-a0d7-16055bc26206', '2025-07-09 07:24:17.150430 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:24:17.150434 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('3661e952-790d-470f-8f35-ee21915a558f', '53129355-2428-4d5a-ab78-f47c9494a9d8', '6f6be908-4316-43c6-adeb-e3dcefd6f5be', '2025-07-09 07:26:15.172737 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:26:15.172741 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('1cf96216-871d-4177-b0b9-1acd85fa0175', 'f8a55e29-67f8-4533-bdee-0c01403b44a5', '399884dc-20e8-4014-b200-72d12b5a9276', '2025-07-09 07:28:28.479458 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:28:28.479462 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('ce4b0b26-f057-4f50-8ae4-0d0d7fb90f3e', 'aa93573d-c125-4b3e-846d-bc008c6a40c4', '93c89345-75a7-4264-8670-b16cec9075a2', '2025-07-09 07:29:52.996299 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:29:52.996309 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('f03803c6-397c-4ca4-8603-cce45ec8174c', '7c1030a1-6c90-46fc-9ea9-e0034362f9d2', '079a0fc3-1516-4ce2-ba62-4939db3bcc08', '2025-07-09 07:30:03.683802 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:30:03.683804 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('33bd7bbb-6ef3-465b-8307-036ec9595d83', '02ed01de-4529-4e3e-8209-d566d30ba279', '1e40b2ce-bd8d-495c-8d87-a240e3a67670', '2025-07-09 07:32:03.101455 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:32:03.101459 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('65b9e7da-1566-403c-a28e-74505cc2871e', 'e8739518-f54b-4c6f-8700-04e2767774da', '3a29ac7a-0a27-4731-90b7-c7577b257d7f', '2025-07-09 07:32:31.187276 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:32:31.187281 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('08e1c302-415c-4a3d-9394-7e1274cfc7d0', '7e3b5663-c8e4-4545-a4f6-b146f7643fca', '2ebd742d-db5d-4fc4-ad65-6f1565e8f61a', '2025-07-09 07:35:15.261538 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:35:15.261541 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('133fa456-7a6b-4e5c-9df6-76ff83f4f21f', '9e7a1a2e-1639-4022-86b7-740c76c67c6c', '0341107d-eb10-4420-a664-d6ad57344c7e', '2025-07-09 07:49:50.664908 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:49:50.664919 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('f3b313ef-667b-43be-be7f-1cc874ab3819', '2841a517-809f-44fa-b0ea-1520e5246905', '0341107d-eb10-4420-a664-d6ad57344c7e', '2025-07-09 07:50:40.184295 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:50:40.184306 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('827423f6-7bca-4108-a5ce-f656ce294e4f', 'b5c9b23d-5226-4f53-ad87-593f92185bd6', '0341107d-eb10-4420-a664-d6ad57344c7e', '2025-07-09 07:51:19.646998 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:51:19.647010 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');
INSERT INTO public.project_module_repo_joins (id, project_module_id, project_item_repo_id, created_at, created_by, updated_at, updated_by) VALUES ('89202b21-13c1-494d-9986-8b7a8b6153b2', 'cdc8fd36-e23f-4bc6-9498-bbf948d4ae87', '0341107d-eb10-4420-a664-d6ad57344c7e', '2025-07-09 07:52:22.944165 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:52:22.944178 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60');

INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('3c3e99d8-67f1-408b-9c9d-3a0d27801bfd', '01fd482d-1ff7-400b-8cb4-fe15e4dfff2b', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/a0df08c4-8e71-4317-8b35-de68b9a384c1/filename', 'null', '2025-07-02 05:53:12.014725', '9999-12-31 00:00:00.000000', '2025-07-02 05:53:12.018143 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-02 05:53:12.018154 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('7ac309a2-ca10-4609-ad39-94063a6b6918', 'baad61a0-566e-4a72-ae22-8e52366460dc', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/fa7a8b10-df67-4032-9d31-237dc488338c/kiosk-main', 'null', '2025-07-09 00:11:03.714996', '9999-12-31 00:00:00.000000', '2025-07-09 00:11:03.715540 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:11:03.715542 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('454d9bf4-6b5f-4df1-9bc9-bd1413c1252d', '875da244-28e1-44e8-b878-3b1a60215555', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/5c5e400c-71da-49db-8cf9-3f063552643f/kiosk-main', 'null', '2025-07-09 00:16:24.279682', '9999-12-31 00:00:00.000000', '2025-07-09 00:16:24.279859 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:16:24.279861 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('a06b34c6-f231-4a6a-9e1f-e1260c071a66', '875da244-28e1-44e8-b878-3b1a60215555', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/da932b38-525b-4d7c-9aaf-e6bb63fabcdc/kiosk-main', 'null', '2025-07-09 00:17:09.268264', '9999-12-31 00:00:00.000000', '2025-07-09 00:17:09.268453 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:17:09.268455 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('7a87d96d-e2b6-4ee6-a9ab-ff7cebee0a4c', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/36ec99c4-6570-4cb3-98a8-eab97f578d76/kiosk-main', 'null', '2025-07-09 00:27:24.913644', '9999-12-31 00:00:00.000000', '2025-07-09 00:27:24.914462 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:27:24.914465 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('63277c23-ddbb-412d-a865-70bae5e043da', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/75060259-5b43-42c3-b934-40a6d7915a37/kiosk-main', 'null', '2025-07-09 00:29:22.232887', '9999-12-31 00:00:00.000000', '2025-07-09 00:29:22.233502 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:29:22.233505 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('83f31fdf-7461-4b2a-a8cb-e419bb85506f', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/f91867e8-970d-4954-8036-ea094b10582a/kiosk-main', 'null', '2025-07-09 00:40:10.852510', '9999-12-31 00:00:00.000000', '2025-07-09 00:40:10.852999 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:40:10.853001 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('35dfdfe1-d3d4-44b7-bebb-88b6682a6134', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/4b9fe532-9bc0-48dc-b955-29307cb6a4b8/kiosk-main', 'null', '2025-07-09 00:40:36.618071', '9999-12-31 00:00:00.000000', '2025-07-09 00:40:36.618497 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:40:36.618502 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('b0df11e0-80dd-4804-b8ec-60c0422bf2fc', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/e5b6d1f6-c518-4986-bab2-9eda9d2aa0e2/kiosk-main', 'null', '2025-07-09 00:42:15.391475', '9999-12-31 00:00:00.000000', '2025-07-09 00:42:15.392932 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:42:15.392939 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('69862013-560d-46e4-aede-57c262816b6f', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/70949118-6e06-4609-8955-046a7084a51b/kiosk-main', 'null', '2025-07-09 00:44:16.203127', '9999-12-31 00:00:00.000000', '2025-07-09 00:44:16.203804 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:44:16.203807 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('4cbd98ba-3281-4970-aec7-8efb8065b4e6', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/481bb338-4873-43bf-99e8-1f99bdd50279/kiosk-main', 'null', '2025-07-09 00:47:39.458863', '9999-12-31 00:00:00.000000', '2025-07-09 00:47:39.460198 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:47:39.460205 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('d432ebe0-33ba-4a09-92ea-52a5c21bb40b', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/65fffd9f-4367-4cd7-867c-8615530c5952/kiosk-main', 'null', '2025-07-09 00:49:03.789330', '9999-12-31 00:00:00.000000', '2025-07-09 00:49:03.789522 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:49:03.789524 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('ee84f75d-3852-4efc-b20b-f2a6ad4c4190', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/d45bc5ac-8d33-408e-9595-d4d7a5cc417d/kiosk-main', 'null', '2025-07-09 00:57:04.227210', '9999-12-31 00:00:00.000000', '2025-07-09 00:57:04.227491 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:57:04.227494 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('4d9a4a6d-0151-4966-ac0c-f9a7075c7eda', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/d2147cbd-7217-4a31-88dd-e38b6f9fcf2f/kiosk-main', 'null', '2025-07-09 00:57:06.763404', '9999-12-31 00:00:00.000000', '2025-07-09 00:57:06.763556 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:57:06.763558 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('99abd4bc-6002-453f-88a1-6179c7bc8b88', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/0edc1e25-6f63-432d-bd64-b3fe53e08fb6/kiosk-main', 'null', '2025-07-09 00:57:07.694905', '9999-12-31 00:00:00.000000', '2025-07-09 00:57:07.695065 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:57:07.695067 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('7a2894f3-b1dc-4789-8d70-860aed1b1d47', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/99704b46-9e41-4f55-9201-9ed8ce922242/kiosk-main', 'null', '2025-07-09 00:57:09.916166', '9999-12-31 00:00:00.000000', '2025-07-09 00:57:09.916299 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 00:57:09.916301 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('d5380be3-01ad-43ee-b758-030a2216c5c2', '4b60b875-02c6-444d-a639-0e41160945bb', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/2797252a-db1a-474c-b38a-63c6fcc3a582/kiosk-main', 'null', '2025-07-09 01:51:23.824883', '9999-12-31 00:00:00.000000', '2025-07-09 01:51:23.825657 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:51:23.825660 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('07a1a065-9a6f-4d92-bee9-7273d5d41400', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/9376f9d2-92ce-4347-b173-4f9db2213476/kiosk-main', 'null', '2025-07-09 01:52:46.199863', '9999-12-31 00:00:00.000000', '2025-07-09 01:52:46.534304 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:52:46.534311 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('4018210f-d9ff-417a-a5cb-f39015aa76c5', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/c13b6ed0-e9b0-452a-866a-2ba105251886/kiosk-main', 'null', '2025-07-09 01:54:31.491341', '9999-12-31 00:00:00.000000', '2025-07-09 01:54:31.519562 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:54:31.519574 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('4fda53a9-baf5-48cd-a1d4-c13da461c592', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/f225d9cd-9499-425d-adc5-7ac023bbd17a/kiosk-main', 'null', '2025-07-09 01:57:48.287178', '9999-12-31 00:00:00.000000', '2025-07-09 01:57:48.315247 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:57:48.315257 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('77b946a5-680a-47b6-82c1-f41e58da15bf', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/240023f6-1648-4f78-a567-fe78429062d9/kiosk-main', 'null', '2025-07-09 01:57:58.179349', '9999-12-31 00:00:00.000000', '2025-07-09 01:57:58.220547 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:57:58.220554 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('18e886d6-bcc8-4e77-b34a-bac6e3e452bb', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/a99f51fd-f380-4956-934b-a3c431813e9e/kiosk-main', 'null', '2025-07-09 01:58:39.037848', '9999-12-31 00:00:00.000000', '2025-07-09 01:58:39.055878 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:58:39.055883 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('35f70f8b-cdb6-4f45-9e1d-9f68045d9929', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/2ea0d202-45dd-4f33-a62d-114f5e8eaa4a/kiosk-main', 'null', '2025-07-09 01:58:41.307493', '9999-12-31 00:00:00.000000', '2025-07-09 01:58:41.332914 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:58:41.332923 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('cdc226e8-5717-41d6-bbb7-5ab8dbff0fee', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/9927fc21-dc61-4c8d-b942-2186be189d5b/kiosk-main', 'null', '2025-07-09 01:58:43.284087', '9999-12-31 00:00:00.000000', '2025-07-09 01:58:43.317255 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:58:43.317271 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('bb0a572e-c352-4c26-a209-24f017f103de', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/2ed2bd82-1285-4b32-92ed-cb5b89ae2b69/kiosk-main', 'null', '2025-07-09 01:58:44.334315', '9999-12-31 00:00:00.000000', '2025-07-09 01:58:44.351067 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 01:58:44.351078 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('f25addbb-84ff-49f9-ac9e-1f753d685322', '4b60b875-02c6-444d-a639-0e41160945bb', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/2a8627f2-c53a-4b31-9b98-34c9f1bf9057/kiosk-main', 'null', '2025-07-09 02:00:09.635477', '9999-12-31 00:00:00.000000', '2025-07-09 02:00:09.637102 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:00:09.637332 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('483b7dd3-711e-4695-a6e7-cfab5951763d', '4b60b875-02c6-444d-a639-0e41160945bb', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/4124b5ac-4bd0-4770-a09e-f144e2bc50b7/kiosk-main', 'null', '2025-07-09 02:04:31.183329', '9999-12-31 00:00:00.000000', '2025-07-09 02:04:31.183632 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:04:31.183636 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('898ded99-afac-4ec1-b818-726ed9edce33', '4b60b875-02c6-444d-a639-0e41160945bb', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/63ccb146-b85c-487f-b6ff-ae372adb11fe/kiosk-main', 'null', '2025-07-09 02:08:07.880230', '9999-12-31 00:00:00.000000', '2025-07-09 02:08:07.880510 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:08:07.880514 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('2900afb1-ff10-4cb1-9bca-a6ab11bfeeec', '4b60b875-02c6-444d-a639-0e41160945bb', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/40a5a3d9-ac6c-40ab-9bfc-aaf04fe48e43/kiosk-main', 'null', '2025-07-09 02:09:42.738411', '9999-12-31 00:00:00.000000', '2025-07-09 02:09:42.738636 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:09:42.738639 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('baff2fb4-f961-4968-ac61-fd9c12c9c3c2', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/208d14eb-5743-425d-9520-0059f608f4a2/kiosk-main', 'null', '2025-07-09 02:11:17.319055', '9999-12-31 00:00:00.000000', '2025-07-09 02:11:17.338600 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:11:17.338607 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('93e65b86-a660-4fec-bbb8-92e1ca844468', '6e867338-c7e3-4199-b541-cd0387c0d276', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/e7b4fa51-000d-441c-a36e-538ca79f4393/kiosk-main', 'null', '2025-07-09 02:12:47.129746', '9999-12-31 00:00:00.000000', '2025-07-09 02:12:47.157932 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 02:12:47.157936 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('4de18cdf-785d-4aa4-87b6-600d306d514b', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/da7a761d-d858-42c5-bd03-6517ebf9d8bb/kiosk-main', 'null', '2025-07-09 04:35:48.427567', '9999-12-31 00:00:00.000000', '2025-07-09 04:35:48.428117 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:35:48.428119 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('81955fd5-37ca-42be-b0bd-509fbcfe6c88', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/cf04be16-a41d-49d2-b70d-82927ab5b12e/kiosk-main', 'null', '2025-07-09 04:36:47.549093', '9999-12-31 00:00:00.000000', '2025-07-09 04:36:47.549397 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:36:47.549401 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('eb3e2827-7163-4cce-8ed0-25b0b0f13ec1', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/bda0dfec-2908-4d43-a816-5e71531db479/kiosk-main', 'null', '2025-07-09 04:44:46.876921', '9999-12-31 00:00:00.000000', '2025-07-09 04:44:46.877698 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:44:46.877702 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('5ac1a4fe-812a-4079-b6fe-0b35fd2816c8', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/1857a3bd-f17a-410e-89b0-fd76381747b5/kiosk-main', 'null', '2025-07-09 04:45:51.791683', '9999-12-31 00:00:00.000000', '2025-07-09 04:45:51.792567 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:45:51.792569 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('6cc1cd1d-9518-49a0-b9ff-7481beb4483f', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/c6158e84-ca01-4c2e-98a4-b4fdea643784/kiosk-main', 'null', '2025-07-09 04:48:47.994879', '9999-12-31 00:00:00.000000', '2025-07-09 04:48:47.995159 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:48:47.995162 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('2ddb99b7-a8f7-4c72-8a44-2d367e88bf0b', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/40f38302-7285-466e-8d24-a30a91d48e55/kiosk-main', 'null', '2025-07-09 04:49:01.477181', '9999-12-31 00:00:00.000000', '2025-07-09 04:49:01.477507 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:49:01.477512 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('a3c38eb2-1d78-42ac-9e05-b80681ed9f0e', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/fe508705-73ec-487c-9ca1-0c1283e175ad/kiosk-main', 'null', '2025-07-09 04:49:10.158086', '9999-12-31 00:00:00.000000', '2025-07-09 04:49:10.158280 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:49:10.158283 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('a2bc3d62-deb8-44e7-b9de-12afce4ea134', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/e3bf7bb5-a3e3-4f1f-b3b8-2d53788a5fb4/kiosk-main', 'null', '2025-07-09 04:56:45.653930', '9999-12-31 00:00:00.000000', '2025-07-09 04:56:45.655045 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:56:45.655050 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('52bf86ba-c754-4617-82a1-b368d6d53779', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/77b2e861-0a7f-45b2-b14e-762e1cdf11aa/kiosk-main', 'null', '2025-07-09 04:58:17.386299', '9999-12-31 00:00:00.000000', '2025-07-09 04:58:17.386603 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:58:17.386607 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('e4ffd247-d9d4-4cb0-9e2d-f4102867f533', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/09da201e-9514-4f96-b699-1980a28ad487/kiosk-main', 'null', '2025-07-09 04:59:44.583974', '9999-12-31 00:00:00.000000', '2025-07-09 04:59:44.584147 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:59:44.584149 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('38bb9db5-d94a-413d-9e4c-bd9848f67e38', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/0d8dcc43-57db-413a-80a2-7f87d221a7d5/kiosk-main', 'null', '2025-07-09 04:59:47.149261', '9999-12-31 00:00:00.000000', '2025-07-09 04:59:47.149414 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 04:59:47.149416 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('a97e573b-3001-40db-8d09-e276368e1e96', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/0d1f4b36-805b-4d5f-a788-b6279c83a272/kiosk-main', 'null', '2025-07-09 05:01:36.644029', '9999-12-31 00:00:00.000000', '2025-07-09 05:01:36.644368 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:01:36.644371 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('86a7e7fc-9b56-4a35-b93a-c10a9e5fbec1', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/653fad01-c536-4c3e-863d-abc53d7b455a/kiosk-main', 'null', '2025-07-09 05:01:56.193992', '9999-12-31 00:00:00.000000', '2025-07-09 05:01:56.194271 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:01:56.194274 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('192f57bc-dd20-472b-8c54-3f8bb198dae9', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/55ab638b-74ef-4fb1-94fe-73617cd496e3/kiosk-main', 'null', '2025-07-09 05:02:06.075148', '9999-12-31 00:00:00.000000', '2025-07-09 05:02:06.075315 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:02:06.075317 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('c3c11233-45d3-4cc3-bd75-679a27682ea7', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/4b695e97-8077-45ed-8931-6cfcffa3a03c/kiosk-main', 'null', '2025-07-09 05:12:19.629865', '9999-12-31 00:00:00.000000', '2025-07-09 05:12:19.630653 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:19.630657 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('7b7868e0-9ed7-4c6b-bb66-33ea8cb63387', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/640e8624-6b1b-4756-bd28-afca32f66cc2/kiosk-main', 'null', '2025-07-09 05:12:40.165572', '9999-12-31 00:00:00.000000', '2025-07-09 05:12:40.165939 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:40.165942 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('05de7bfc-d6a5-4c0f-a6dc-3926feef32a6', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/7b3c3ac1-763d-4b25-8bd7-807e480cba5b/kiosk-main', 'null', '2025-07-09 05:12:48.875102', '9999-12-31 00:00:00.000000', '2025-07-09 05:12:48.875294 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:48.875296 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('1b5f9148-9d91-4060-8b06-c162949a762e', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/4b4585e6-3dd2-4b3b-831e-b2d454093702/kiosk-main', 'null', '2025-07-09 05:12:56.867381', '9999-12-31 00:00:00.000000', '2025-07-09 05:12:56.867656 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:12:56.867659 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('aa9a4107-fa1d-456d-be65-9dc94c1a0145', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/0e616953-e7d5-4766-9205-54d13af9918d/kiosk-main', 'null', '2025-07-09 05:18:04.448221', '9999-12-31 00:00:00.000000', '2025-07-09 05:18:04.449294 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:18:04.449298 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('89fa33c9-8707-4a8f-8b71-d8533be8d7a4', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/c22ae8aa-8258-4fb3-96c3-fc19702a103f/kiosk-main', 'null', '2025-07-09 05:28:20.449145', '9999-12-31 00:00:00.000000', '2025-07-09 05:28:20.450085 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:28:20.450090 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('a873cbb6-3d2c-4415-98fc-8ecdf69a5cf3', '02fdfd95-7e30-4f34-8241-c6989fdbd4ec', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/96dcd53d-0c62-4083-94df-49709039ddfc/kiosk-main', 'null', '2025-07-09 05:32:45.385415', '9999-12-31 00:00:00.000000', '2025-07-09 05:32:45.386987 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:32:45.386993 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('09453092-bd5a-452d-8333-f3acdbac54ee', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/831f517a-6fb3-4e51-848e-6c97206e6113/kiosk-main', 'null', '2025-07-09 05:33:32.352587', '9999-12-31 00:00:00.000000', '2025-07-09 05:33:32.354583 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:33:32.354592 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('0c039935-9b73-4324-a84e-610f39b3095a', '02fdfd95-7e30-4f34-8241-c6989fdbd4ec', 'zip', 'kiosk-main', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/fc0b4c2f-b017-499f-921b-edb5632d8384/kiosk-main', 'null', '2025-07-09 05:33:46.851794', '9999-12-31 00:00:00.000000', '2025-07-09 05:33:46.852773 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:33:46.852777 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('0b9c4ffd-b737-4689-acd4-5b12e36b6d45', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/4e8a086d-cc76-4f06-a01d-137259ca15a4/kiosk-main', 'null', '2025-07-09 05:34:32.635157', '9999-12-31 00:00:00.000000', '2025-07-09 05:34:32.635853 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:34:32.635857 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('51faf6d9-85c1-4fff-bdc0-d4baf9e297bc', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/a3e9d09e-73ec-4a0b-b2d3-310815bb95b6/kiosk-main', 'null', '2025-07-09 05:36:33.686638', '9999-12-31 00:00:00.000000', '2025-07-09 05:36:33.687390 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:36:33.687394 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('61466cc9-3ad4-469d-bc45-4a59db7d3e20', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/fc1b350d-84c4-4600-ae72-4b0d3b9c43a1/kiosk-main', 'null', '2025-07-09 05:41:27.203219', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:27.203903 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:27.203906 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('c7c9f088-7f05-4918-b056-6298e6c59168', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/274f7766-d030-4485-923c-0e969a457f09/kiosk-main', 'null', '2025-07-09 05:41:33.305309', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:33.305478 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:33.305480 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('9eab4d66-15eb-4286-90ff-dde43c9bafb0', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/374a376b-2f97-41a8-a518-8f7ce541421d/kiosk-main', 'null', '2025-07-09 05:41:37.605029', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:37.605181 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:37.605183 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('b3413e6c-81fb-4241-a9aa-90cf1f4eaa60', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/5722bd74-25d9-4576-90d5-8d6168c985bf/kiosk-main', 'null', '2025-07-09 05:41:41.956268', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:41.956469 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:41.956471 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('b7252847-af48-4e76-8ff0-35816d8c645f', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/721ea631-8763-43b3-b1f4-606aec19663d/kiosk-main', 'null', '2025-07-09 05:41:46.100189', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:46.100333 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:46.100335 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('2075f4e1-3a07-44cf-8d49-8d18dc371825', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/7c4e9c4a-4428-4404-b1df-e8d4c7dc3ee5/kiosk-main', 'null', '2025-07-09 05:41:50.881489', '9999-12-31 00:00:00.000000', '2025-07-09 05:41:50.881675 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 05:41:50.881677 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('633a87fc-68a1-44cd-9b4b-a555c5aea03d', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/1737db5c-ee39-4366-b840-3e1b781389ed/kiosk-main', 'null', '2025-07-09 06:18:46.526763', '9999-12-31 00:00:00.000000', '2025-07-09 06:18:46.527080 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:46.527082 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('f099a262-22d6-41fd-946b-242394ca35b7', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/a8e48009-f8f0-408c-ae33-32f7f5b895f4/kiosk-main', 'null', '2025-07-09 06:18:52.017282', '9999-12-31 00:00:00.000000', '2025-07-09 06:18:52.017511 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:52.017514 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('e3c90284-9b85-40d7-ab57-db0dcd3ff2b5', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/47b5365a-6f5c-4e8f-bcf0-ea4e2f2f6399/kiosk-main', 'null', '2025-07-09 06:18:56.273442', '9999-12-31 00:00:00.000000', '2025-07-09 06:18:56.273610 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 06:18:56.273612 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', null, null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('5f9158d9-58e3-4354-a8d6-b8be08857249', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/b5dadb28-faac-4405-b730-1b6a3d2eba24/kiosk-main', 'null', '2025-07-09 07:03:17.134300', '9999-12-31 00:00:00.000000', '2025-07-09 07:03:17.134948 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:03:17.134950 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '8ce277c4-a71c-41b4-bab2-1e8ce0f3f372', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('c7fb3d09-03a2-4f7f-96b4-de7c17f08d5d', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/87bd1e2c-a0f6-486c-ab36-c3c2307e462f/kiosk-main', 'null', '2025-07-09 07:07:19.312993', '9999-12-31 00:00:00.000000', '2025-07-09 07:07:19.313526 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:07:19.313528 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2ca2ff91-4ff3-43e4-918f-bf0294e25f64', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('52fd4e5b-c8a5-4bdd-95d2-472abc18b628', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/f2afc0ac-8e41-4140-8ee8-4429c4dfbc5f/kiosk-main', 'null', '2025-07-09 07:12:04.196430', '9999-12-31 00:00:00.000000', '2025-07-09 07:12:04.197242 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:12:04.197246 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '99db1d3b-95e3-4089-b4bc-60f482145e3a', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('7b1f2c67-4715-48be-abd1-117fefedc8a3', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/61bfc1ba-91a7-4457-ac48-ca661d7b5abf/kiosk-main', 'null', '2025-07-09 07:12:46.532811', '9999-12-31 00:00:00.000000', '2025-07-09 07:12:46.533553 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:12:46.533556 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '06facba7-78e6-45e3-a351-b763e24f3a4e', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('f7c85542-3cc0-4b25-a493-81e444bd3122', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/f5db567e-5205-456f-8e20-8105af10a1f4/kiosk-main', 'null', '2025-07-09 07:13:31.296931', '9999-12-31 00:00:00.000000', '2025-07-09 07:13:31.297123 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:13:31.297125 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'ef555384-6953-48ef-abd2-e9b2d3a13e9f', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('bdecf1f3-28d3-4a54-9306-1efa904e3a88', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/a2628d62-931b-4075-8784-6ff305eeafc2/kiosk-main', 'null', '2025-07-09 07:16:22.816241', '9999-12-31 00:00:00.000000', '2025-07-09 07:16:22.817145 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:16:22.817149 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '0b2e0ed6-605f-4564-9782-b46a3e6bd8ed', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('f0fcd0d4-dc9b-404b-98b2-5919e4eb2681', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/7cc42efe-669a-405d-bfdd-f99322fd4b77/kiosk-main', 'null', '2025-07-09 07:20:01.779653', '9999-12-31 00:00:00.000000', '2025-07-09 07:20:01.780415 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:20:01.780418 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'e3815b2f-2ba9-4373-8ee7-e37055a3b2cb', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('459c04bf-617c-479b-aa28-edc94ad0d17c', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/5a6528f6-3aa2-4440-91cd-d398a55fb7cb/kiosk-main', 'null', '2025-07-09 07:21:30.229388', '9999-12-31 00:00:00.000000', '2025-07-09 07:21:30.229872 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:21:30.229874 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '7e3f260c-6f1e-402e-948f-67b42adcf45f', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('9e7312d2-54b2-43f3-a0d7-16055bc26206', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/74a37dc4-61f9-45aa-b54b-cf84aa08c28a/kiosk-main', 'null', '2025-07-09 07:24:17.017835', '9999-12-31 00:00:00.000000', '2025-07-09 07:24:17.018547 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:24:17.018551 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'b07e59f3-c186-4909-9e67-9cf0e73ea8fa', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('6f6be908-4316-43c6-adeb-e3dcefd6f5be', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/5dfb981a-7f7d-4e0b-855c-2593ea297cd7/kiosk-main', 'null', '2025-07-09 07:26:15.086484', '9999-12-31 00:00:00.000000', '2025-07-09 07:26:15.087178 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:26:15.087181 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'dc05829b-6dd6-4cac-9b41-bb9b77c01b34', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('399884dc-20e8-4014-b200-72d12b5a9276', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/7df81082-0125-4691-bebf-767aadc9f4df/kiosk-main', 'null', '2025-07-09 07:28:28.290525', '9999-12-31 00:00:00.000000', '2025-07-09 07:28:28.291067 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:28:28.291069 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '17d94ebf-05c1-479d-bb7b-693830270ba1', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('93c89345-75a7-4264-8670-b16cec9075a2', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/2a4ba675-f34a-4c55-8baa-1d8aad103564/kiosk-main', 'null', '2025-07-09 07:29:52.771367', '9999-12-31 00:00:00.000000', '2025-07-09 07:29:52.772197 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:29:52.772200 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'f6549e1b-ee15-4876-a018-aaeef61261b0', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('079a0fc3-1516-4ce2-ba62-4939db3bcc08', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/fb2a6f0a-7453-47f7-a2e0-aa96bf3b8d86/kiosk-main', 'null', '2025-07-09 07:30:03.587633', '9999-12-31 00:00:00.000000', '2025-07-09 07:30:03.587918 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:30:03.587920 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '1606e996-71ad-48d1-a1c5-374ce00fd25a', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('1e40b2ce-bd8d-495c-8d87-a240e3a67670', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/6458aa85-a7b6-49cd-baae-12aa9e0ce147/kiosk-main', 'null', '2025-07-09 07:32:02.945503', '9999-12-31 00:00:00.000000', '2025-07-09 07:32:02.946368 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:32:02.946372 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'a7ec5c92-4235-4172-918c-5e39f1d1fad6', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('3a29ac7a-0a27-4731-90b7-c7577b257d7f', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/a336cdce-efaa-46be-9311-e04ed8355400/kiosk-main', 'null', '2025-07-09 07:32:31.015187', '9999-12-31 00:00:00.000000', '2025-07-09 07:32:31.015873 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:32:31.015876 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'f6b72f31-2f7a-43cc-a147-919d28d90647', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('2ebd742d-db5d-4fc4-ad65-6f1565e8f61a', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'filename.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/293dee4e-ccad-4883-9c9e-51378840ad30/kiosk-main', 'null', '2025-07-09 07:35:14.833197', '9999-12-31 00:00:00.000000', '2025-07-09 07:35:14.834250 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:35:14.834255 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '9b709b2d-8fd6-417b-a75a-d7596d932339', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('16990e12-ab69-4340-ac45-d44819d9d84c', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'kiosk-main.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/2971f36a-7f36-4fba-8a99-ba0e8462132e/kiosk-main', 'null', '2025-07-09 07:40:19.437814', '9999-12-31 00:00:00.000000', '2025-07-09 07:40:19.438079 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:40:19.438082 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '25650957-10a3-4d2c-9ba8-104173622975', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('53101b3a-1aa1-4b8f-b523-e855e31ebabc', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'kiosk-main.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/6486a4c1-7c71-462c-8d3d-d9fbd86aedae/kiosk-main', 'null', '2025-07-09 07:42:03.988107', '9999-12-31 00:00:00.000000', '2025-07-09 07:42:03.988805 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:42:03.988809 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'b9f2145e-d102-4522-a2a5-ee5499082613', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('ceb470da-ecd6-472f-8790-6cc02fce0b4d', 'ee16f91e-322c-4139-8d8c-f05c480faa63', 'zip', 'kiosk-main.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/fb7509b4-7487-4fc7-93d6-d5f4e05237de/kiosk-main', 'null', '2025-07-09 07:44:16.670625', '9999-12-31 00:00:00.000000', '2025-07-09 07:44:16.671358 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:44:16.671362 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'fb378de0-e9ab-48ec-971f-74d8c3d3ecd3', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('b0fb35b8-9b1c-492c-b8dd-e5f0c0cc709c', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'zip', 'kiosk-main.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/88cbf1c9-9b96-4509-aebc-7f0b7f214f90/kiosk-main', 'null', '2025-07-09 07:45:48.778930', '9999-12-31 00:00:00.000000', '2025-07-09 07:45:48.779746 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:45:48.779749 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '9578da48-1e0a-4384-9f37-3d02edc1f890', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('4839ac1b-5481-42a5-bf5a-4978be65cb6b', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'zip', 'kiosk-main.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/279a2889-7092-4991-92cf-ca9f2ce82794/kiosk-main', 'null', '2025-07-09 07:46:24.929411', '9999-12-31 00:00:00.000000', '2025-07-09 07:46:24.930379 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:46:24.930383 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'c0daa7f1-f3e3-4d97-a52e-940d3c142042', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('6c50b913-aa6d-48e9-94e7-4017d661401e', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'zip', 'kiosk-main.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/9b5db9c1-465d-4517-a1fa-26f5f1b54c7f/kiosk-main', 'null', '2025-07-09 07:46:47.033994', '9999-12-31 00:00:00.000000', '2025-07-09 07:46:47.034407 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:46:47.034411 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', 'e114e21e-83cd-4487-b988-52715539dfa1', null);
INSERT INTO public.project_item_repos (id, project_id, repo_type, repo_name, repo_path, repo_auth, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by, upload_file_id, project_module_id) VALUES ('0341107d-eb10-4420-a664-d6ad57344c7e', '4df04efd-e1a0-48c5-9be7-c1156e054ea7', 'zip', 'kiosk-main.zip', 'upload_files/aaf7ddd6-6b6d-467d-bacf-e238e314e737/8c83a779-da5d-4362-a042-802bb6819d1f/kiosk-main', 'null', '2025-07-09 07:47:16.355169', '9999-12-31 00:00:00.000000', '2025-07-09 07:47:16.355926 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '2025-07-09 07:47:16.355929 +00:00', 'e71b8811-add9-4a4d-ac43-4cc1eec10d60', '17c250ad-3e64-48b6-aa4e-3202adf2b2bd', null);

INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('da76f61b-dc58-4ddc-ad9c-355501959c75', '123e4567-e89b-12d3-a456-426614174000', null, '개요', '60be7706-a920-4738-a600-30cc390d246c', 0, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('4d49e353-9f1a-409a-920b-188ee73141ab', '123e4567-e89b-12d3-a456-426614174000', null, 'GPU 대시보드 구성', '15bdd145-9962-4077-bf86-cd14e8921fd5', 1, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('10fb17d6-368d-4406-bb3f-e4c71838025d', '123e4567-e89b-12d3-a456-426614174000', null, 'GPU 대시보드 기능', '48353c08-4382-4f26-876d-a6e988e160cc', 2, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('69706cd0-dfe1-45ef-8413-491ee235b19d', '123e4567-e89b-12d3-a456-426614174000', null, '쿠버네티스 연동', '37257df8-bb99-4e03-a80b-1a0a53e2312e', 3, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('1a515167-22a2-41d4-8192-0a97f2967c35', '123e4567-e89b-12d3-a456-426614174000', null, '로깅 프레임워크 통합', '6f28f36e-f65b-476f-a7c2-5c307df5784a', 4, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('01fda1ac-7ea7-409a-985d-49c4ccb49c48', '123e4567-e89b-12d3-a456-426614174000', '4d49e353-9f1a-409a-920b-188ee73141ab', 'GPU 대시보드 설정', 'd103e5cc-a404-4d48-9000-dbc1025e5ecb', 0, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('2f3bdcb8-06a0-4d41-a7b9-cb350555f92c', '123e4567-e89b-12d3-a456-426614174000', '4d49e353-9f1a-409a-920b-188ee73141ab', 'GPU 대시보드 데이터 및 엔티티 관리', 'a7867408-e2f3-4925-9e00-851d7ae71b5e', 1, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('54b45ab5-29d5-4dd0-a1b9-f974cce31364', '123e4567-e89b-12d3-a456-426614174000', '4d49e353-9f1a-409a-920b-188ee73141ab', 'GPU 대시보드 데이터 저장소', '3d9dda2d-4151-4111-8fce-b2e1a41adaf3', 2, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('5a998c3e-0bce-4477-a448-205cd87008d2', '123e4567-e89b-12d3-a456-426614174000', '10fb17d6-368d-4406-bb3f-e4c71838025d', 'GPU 대시보드 서비스', '3fc8fa68-8d9e-4366-8a64-82639f49a82a', 0, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('8d88b584-18df-4e43-ae35-084d398b6820', '123e4567-e89b-12d3-a456-426614174000', '10fb17d6-368d-4406-bb3f-e4c71838025d', 'GPU 대시보드 컨트롤러', '61f44b7d-40e6-4294-b9ef-762a9f9b56fe', 1, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('41fcc85c-244b-4d89-aa24-cdfb0a2e8319', '123e4567-e89b-12d3-a456-426614174000', '69706cd0-dfe1-45ef-8413-491ee235b19d', '쿠버네티스 오픈API 클라이언트 모델 및 API', '3820c7e3-a964-4caa-99b2-5f68a67cd326', 0, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('b1141a1e-c6ff-4ecb-812a-c4ede5601281', '123e4567-e89b-12d3-a456-426614174000', '69706cd0-dfe1-45ef-8413-491ee235b19d', '쿠버네티스 클라이언트 유틸리티', 'ea400d05-4b5f-4788-bed0-36a68bc328f8', 1, '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('cd77e0e1-514c-4c63-9edc-10eba7e3f56a', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', 'ec15484f-8483-48ca-99c9-2abaf91faecb', '공통 및 유틸리티 기능 모듈', 'fc97e3f2-fa63-4c93-a8e9-293025121bbc', 0, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('6de4e770-ab8c-4681-a7f8-a1954d3573ec', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', 'ec15484f-8483-48ca-99c9-2abaf91faecb', '데이터프레임 유틸리티 함수', '8931295b-b049-4e47-9be3-024104e70d36', 1, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('5e9baf08-2309-470b-bee2-a20be4bab46c', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', 'ec15484f-8483-48ca-99c9-2abaf91faecb', '웹로직 공통 기능', '0b16e18c-e5be-49d8-b54c-efd02fd06e51', 2, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('db0404c6-ad10-4467-96e4-05b8ef8454d0', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', 'ec15484f-8483-48ca-99c9-2abaf91faecb', '기본 소프트웨어 패키지 목록', '13a8f99e-47f1-4bf8-98a1-e46896a56f0a', 3, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('dcbba43c-5e47-4c28-84c5-16c7675d8463', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '32885eab-07b9-48b2-bb51-a62e0f6e52e9', '데이터베이스 엔티티 및 접근 객체 구성', 'ff44ced8-ee96-47bb-ab8a-944766915d29', 0, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('40832781-80d3-4a52-bd15-dccd88748967', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '32885eab-07b9-48b2-bb51-a62e0f6e52e9', '설정 및 XML 관리', '20739092-3d9a-4902-9dce-e2fb6727f28c', 1, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('fb6d13e7-1926-4536-af6c-db430a762b6d', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '32885eab-07b9-48b2-bb51-a62e0f6e52e9', 'EJBean 데이터 처리', '1f636485-e662-4d04-bad2-36b0fb67b0cf', 2, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('b6d05ee1-c1b6-4bd9-af2a-3bd05d1f1963', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '2f357949-e3e2-47e7-a1e1-0546a7507b3a', '세션빈 기반 업무처리 모듈', '8b76510c-643d-4bf1-be47-8b9d174d9cb9', 0, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('c5aabd0c-05dc-4fb4-b3e7-94aa3e59a40e', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '2f357949-e3e2-47e7-a1e1-0546a7507b3a', '금융코어시스템 기능 모듈', '5d3f00ea-01bb-430e-a420-8c492b976bc0', 1, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('639361c6-e432-407c-8ff4-a7a64feda5ea', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '2f357949-e3e2-47e7-a1e1-0546a7507b3a', 'SRPT 보고서 세션빈 모듈', 'bf31f06b-5110-41b3-b518-219c0406917c', 2, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('56d5907a-409b-4f7a-a3d9-295aa45c8087', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '545d89a3-8783-41ef-9c46-1c8ca42d6a9a', '가우스 데이터 처리 패키지', '857a610e-3876-45ad-84eb-ec0f87974c8b', 0, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('009b62e7-693a-4240-879d-8ba3503717b4', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '545d89a3-8783-41ef-9c46-1c8ca42d6a9a', '서블릿 및 필터 처리 모듈', 'eca923c9-5bf7-4b52-a95a-c423ce783b7e', 1, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('21d7dce1-d11d-46e0-a3a0-51f493b7f316', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '293e9638-2fc8-4c2a-8217-147a990e8893', '로그 및 메시지 이벤트 관리', 'b7acadfd-c89f-43c4-84ff-1e77b4c7b29c', 0, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('3b6d1779-a3dc-4881-a396-c61895116f52', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', '293e9638-2fc8-4c2a-8217-147a990e8893', '스윙 기반 UI 및 그래프 기능', 'f791ef6c-1ea5-4502-948b-0aa387adb38c', 1, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('02d679c0-431a-424b-80cc-0ffdf2795c28', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', null, '개요', 'd04c7be7-5654-443e-a9b2-09ab5f4b4b4e', 0, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('ec15484f-8483-48ca-99c9-2abaf91faecb', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', null, '공통기반 및 유틸리티', '475ab0f3-465a-4df3-9111-24a2b9a4fa34', 1, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('32885eab-07b9-48b2-bb51-a62e0f6e52e9', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', null, '데이터 관리', '1908cdbe-b8f0-4b90-a66f-a58610667b48', 2, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('2f357949-e3e2-47e7-a1e1-0546a7507b3a', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', null, '업무 및 금융 모듈', '4c14f6fe-a8e4-4dd1-af81-beefd4bc15d4', 3, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('545d89a3-8783-41ef-9c46-1c8ca42d6a9a', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', null, '데이터 처리 및 통신', '4aca96ef-8792-4468-a92e-a9ef8dd81418', 4, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');
INSERT INTO public.pages (id, project_module_id, parent_id, title, content_id, "order", created_at, created_by, updated_at, updated_by, version) VALUES ('293e9638-2fc8-4c2a-8217-147a990e8893', 'b8f9c5a2-4d3f-4db8-a2a1-87d85e7ac301', null, '로그 및 UI 관리', '2784b8eb-2abc-4e36-a12f-556c4221b56c', 5, '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, '1.0.0');

INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('a46690b1-85b4-4ee4-9cfa-e836b8419a7e', e'# EJBean 데이터 처리

## 소개

EJBean 데이터 처리 시스템은 엔터프라이즈 Java 환경에서 데이터베이스, 메시지, 화면, 코드, 예외, 로깅 등 다양한 엔터프라이즈 기능을 표준화하고, 확장성·안정성·유지보수성을 극대화하기 위해 설계된 통합 데이터 처리 프레임워크입니다.
본 문서는 주요 컴포넌트(데이터베이스 접근, 커넥션 풀, 코드/메시지 관리, 예외/로깅, 화면 관리 등)의 구조와 데이터 흐름, 아키텍처적 역할, 각 계층의 책임 및 상호작용을 체계적으로 설명합니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 주요 레이어와 컴포넌트 간 의존성 및 호출 흐름을 시각적으로 나타냅니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        SM["ScreenManager"]
        CM["CodeManager"]
        MSGM["MsgManager"]
    end
    subgraph "Business Layer"
        EJBUtil["EJBUtil"]
        JSessionBean["JSessionBean"]
        JEntityBean["JEntityBean"]
    end
    subgraph "Data Access Layer"
        DBConnManager["DBConnManager"]
        DBConnPool["DBConnPool\\n(DBConnPool_WL, DBConnPool_9I, DBConnPool_AP)"]
        JConnection["JConnection"]
        JStatement["JStatement"]
        JPreparedStatement["JPreparedStatement"]
        JResultSet["JResultSet"]
        DBObjectManager["DBObjectManager"]
        DBObject["DBObject\\n(DBObject_ORA, DBObject_MSSQL)"]
        DBCodeConverter["DBCodeConverter"]
    end
    subgraph "Messaging Layer"
        JMSMsgSender["JMSMsgSender"]
        JMSMsgReceiver["JMSMsgReceiver"]
        JMSMsgQueue["JMSMsgQueue"]
    end
    subgraph "Exception/Logging Layer"
        JEJBException["JEJBException"]
        DBException["DBException"]
        JException["JException"]
        Log["Log"]
        LogWriter["LogWriter"]
        StackTraceParser["StackTraceParser"]
        StackTrace["StackTrace"]
        Location["Location"]
    end
    subgraph "Configuration Layer"
        Configuration["Configuration"]
        Const["Const"]
    end

    %% 호출 흐름
    SM --> CM
    SM --> MSGM
    SM --> Configuration
    CM --> Configuration
    MSGM --> Configuration

    EJBUtil --> JSessionBean
    EJBUtil --> JEntityBean
    EJBUtil --> JEJBException
    EJBUtil --> Configuration

    JSessionBean --> JEJBException
    JEntityBean --> JEJBException

    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JStatement
    JConnection --> JPreparedStatement
    JStatement --> JResultSet
    JPreparedStatement --> JResultSet
    JConnection --> DBCodeConverter
    JStatement --> DBCodeConverter
    JPreparedStatement --> DBCodeConverter
    DBConnManager --> DBObjectManager
    DBObjectManager --> DBObject
    DBObject --> DBCodeConverter
    DBObject --> Configuration

    JMSMsgSender --> JMSMsgQueue
    JMSMsgReceiver --> JMSMsgQueue

    JStatement --> DBException
    JPreparedStatement --> DBException
    JConnection --> DBException
    DBConnManager --> DBException
    DBObject --> DBException
    JEJBException --> JException
    DBException --> JException

    Log --> LogWriter
    LogWriter --> StackTraceParser
    LogWriter --> StackTrace
    StackTrace --> Location

    Configuration --> Const
```
*위 다이어그램은 각 레이어별 주요 컴포넌트와 호출/의존 흐름을 나타냅니다.*

---

# 주요 컴포넌트 및 데이터 흐름

## 1. 데이터베이스 접근 계층

### 1.1. 커넥션 풀 및 커넥션 관리

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Data Access Layer"
        DBConnManager
        DBConnPool
        JConnection
        JStatement
        JPreparedStatement
        JResultSet
    end
    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JStatement
    JConnection --> JPreparedStatement
    JStatement --> JResultSet
    JPreparedStatement --> JResultSet
```
*DBConnManager를 통해 커넥션 풀에서 JConnection을 획득, Statement/PreparedStatement/ResultSet을 생성 및 관리합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| DBConnManager    | DBConnPool 구현체를 동적으로 로딩, 커넥션 획득/반납의 단일 진입점                        |
| DBConnPool       | 커넥션 풀 인터페이스, 다양한 구현체(DBConnPool_WL, DBConnPool_9I, DBConnPool_AP 등) 지원 |
| JConnection      | JDBC Connection 래퍼, 트랜잭션/속성/Statement 생성 등 DB 연결 관리                        |
| JStatement       | JDBC Statement 래퍼, SQL 실행/로깅/예외 처리/성능 측정 등 부가 기능 제공                  |
| JPreparedStatement| PreparedStatement 래퍼, 파라미터 관리/로깅/예외 처리/성능 측정 등 부가 기능 제공         |
| JResultSet       | ResultSet 래퍼, 데이터 추출/변환/예외 처리/코드 변환 등 부가 기능 제공                   |

#### 예시 코드

```java
JConnection conn = DBConnManager.getConnection();
JPreparedStatement pstmt = conn.prepareStatement("SELECT * FROM USER WHERE ID = ?");
pstmt.setInt(1, 1001);
JResultSet rs = pstmt.executeQuery();
while(rs.next()) {
    String name = rs.getString("NAME");
    // ...
}
DBConnManager.close(conn);
```

---

### 1.2. DB 객체 및 ID 생성 전략

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Data Access Layer"
        DBObjectManager
        DBObject
        MaxIDGen
        SeqIDGen
        SPIDGen
    end
    DBObjectManager --> DBObject
    DBObject --> MaxIDGen
    DBObject --> SeqIDGen
    DBObject --> SPIDGen
```
*DBObjectManager가 DBMS별 DBObject 구현체와 다양한 IDGen 전략을 관리합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| DBObjectManager  | DBMS별 DBObject 구현체 및 IDGen 전략의 중앙 관리/주입                                     |
| DBObject         | DB 객체 추상 클래스, IDGen 인터페이스 구현, 컬럼 주석 조회 등 표준화                      |
| MaxIDGen/SeqIDGen/SPIDGen | 다양한 ID 생성 정책(최대값, 시퀀스, 저장 프로시저 등) 구현체                    |

#### 예시 코드

```java
DBObject dbo = DBObjectManager.getDBObject();
String nextId = dbo.getNextID("USER", "ID", null);
```

---

### 1.3. DB 코드 변환 및 환경설정

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Data Access Layer"
        DBCodeConverter
    end
    DBCodeConverter --> Configuration
```
*DBCodeConverter는 환경설정에 따라 문자셋 변환을 수행합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| DBCodeConverter  | DB ↔ 애플리케이션 간 문자셋 변환(인코딩) 유틸리티                                        |
| Configuration    | 환경설정 파일 관리, 설정값 조회/타입 변환/예외 처리 등                                    |

---

## 2. 메시지/코드/화면 관리 계층

### 2.1. 코드/메시지/화면 관리

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Presentation Layer"
        CodeManager
        MsgManager
        ScreenManager
    end
    CodeManager --> Configuration
    MsgManager --> Configuration
    ScreenManager --> CodeManager
    ScreenManager --> MsgManager
```
*CodeManager/MsgManager/ScreenManager는 환경설정에 따라 코드/메시지/화면 정의를 관리합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| CodeManager      | 코드 테이블 관리, 코드명/표시명/관계코드/콤보박스 생성 등 지원                            |
| MsgManager       | 메시지 관리, 메시지 타입/내용 조회, 다국어 지원                                            |
| ScreenManager    | 화면 정의(XML) 관리, 화면 블록/타입/구성 정보 제공                                       |

---

## 3. 예외/로깅 계층

### 3.1. 예외 처리

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Exception/Logging Layer"
        JException
        JEJBException
        DBException
        JMailException
        JPropertiesException
        ConfigurationException
    end
    JEJBException --> JException
    DBException --> JException
    JMailException --> JException
    JPropertiesException --> JException
    ConfigurationException --> JException
```
*모든 도메인별 예외는 JException을 상속하여 일관된 예외 처리 체계를 구성합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| JException       | 커스텀 예외의 최상위 클래스, 코드/메시지/원인 예외 등 다양한 정보 래핑                    |
| JEJBException    | EJB 환경 특화 예외, 시스템 예외 래핑 및 추가 정보 제공                                    |
| DBException      | DB 작업 특화 예외, SQLException 등 래핑                                                  |
| JMailException   | 메일 처리 특화 예외                                                                      |
| JPropertiesException | 설정 파일 처리 특화 예외                                                             |
| ConfigurationException | 환경설정 처리 특화 예외                                                            |

---

### 3.2. 로깅 및 스택 트레이스

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Exception/Logging Layer"
        Log
        LogWriter
        StackTraceParser
        StackTrace
        Location
    end
    Log --> LogWriter
    LogWriter --> StackTraceParser
    LogWriter --> StackTrace
    StackTrace --> Location
```
*Log/LogWriter는 로그 레벨별 로그 기록, StackTrace/Location은 코드 위치 정보 추출 및 포맷을 담당합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| Log              | 로그 레벨별(LogWriter) 인스턴스 제공, 중앙 로그 진입점                                    |
| LogWriter        | 로그 레벨/포맷/파일/콘솔 출력/동기화 등 로깅 정책 관리                                    |
| StackTraceParser | 예외 스택 트레이스 파싱, 호출자/오너 클래스명 추출                                       |
| StackTrace       | 실행 시점의 스택 트레이스 캡처 및 Location 객체화                                         |
| Location         | 스택 프레임 한 줄을 구조화(패키지/클래스/메서드/파일/라인)                                |

---

## 4. 메시징 계층

### 4.1. JMS 메시지 송수신

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Messaging Layer"
        JMSMsgSender
        JMSMsgReceiver
        JMSMsgQueue
    end
    JMSMsgSender --> JMSMsgQueue
    JMSMsgReceiver --> JMSMsgQueue
```
*JMSMsgSender/Receiver는 JMSMsgQueue를 통해 메시지 송수신을 수행합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| JMSMsgSender     | JMS 메시지 생성(ObjectMessage 등), 큐 송신, 종료 신호 전송 등 송신 표준화                 |
| JMSMsgReceiver   | JMS 큐로부터 메시지 동기 수신, 예외 처리/로깅/자원 관리                                   |
| JMSMsgQueue      | JMS 큐/커넥션 팩토리 관리, 송수신자에 큐 객체 제공                                       |

---

## 5. 환경설정 계층

### 5.1. 환경설정 및 상수 관리

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Configuration Layer"
        Configuration
        Const
    end
    Configuration --> Const
```
*Configuration은 환경설정 파일을 관리하며, Const는 전역 상수를 제공합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| Configuration    | 환경설정 파일 로딩, 설정값 조회/타입 변환/예외 처리 등                                    |
| Const            | 시스템 전역 상수(환경설정 키, 코드값, DBMS/서버/인코딩/언어 등) 집합                      |

---

# 데이터 모델 및 API 요약

## 1. 주요 데이터 모델 (예시)

| 필드명      | 타입      | 설명                         |
|-------------|-----------|------------------------------|
| Msg.type    | String    | 메시지 유형 (ERR/INFO 등)    |
| Msg.message | String    | 메시지 내용                  |
| Screen.name | String    | 화면 이름                    |
| Screen.blocks | Map     | 블록명 → 블록 내용           |
| Screen.block_types | Map| 블록명 → 블록 타입           |
| PagedList.totalCnt | int| 전체 데이터 건수             |
| PagedList.pList | List | 현재 페이지 데이터 리스트     |

---

## 2. 주요 API/메서드 (예시)

| 메서드명                         | 파라미터/타입                | 설명                                   |
|-----------------------------------|------------------------------|----------------------------------------|
| DBConnManager.getConnection()     | 없음                         | JConnection 객체 획득                  |
| JConnection.prepareStatement(sql) | String                       | JPreparedStatement 생성                |
| JPreparedStatement.executeQuery() | 없음                         | JResultSet 반환                        |
| CodeManager.getCodeName(code)     | String                       | 코드값으로 코드명 조회                 |
| MsgManager.getMessage(id)         | String                       | 메시지 ID로 메시지 내용 조회           |
| JMSMsgSender.sendMessage(msg)     | Object                       | JMS 메시지 송신                        |
| JMSMsgReceiver.receiveMessage()   | 없음                         | JMS 메시지 수신                        |
| Log.info.println(msg)             | String                       | 정보 로그 기록                         |

---

## 3. 예외/로깅/메시지 구조

| 예외 클래스         | 주요 필드/메서드            | 설명                                 |
|---------------------|----------------------------|--------------------------------------|
| JException          | code, detail, msg          | 예외 코드, 원인 예외, 메시지 객체    |
| JEJBException       | sqlDetail, dbDetail, msg   | SQL/DB 예외, 메시지 객체            |
| DBException         | sqlDetail, msg             | SQL 예외, 메시지 객체               |
| LogWriter.println() | 다양한 오버로딩            | 로그 메시지/예외/스택트레이스 기록  |

---

# 결론

EJBean 데이터 처리 시스템은 엔터프라이즈 Java 환경에서 데이터베이스, 메시지, 코드, 화면, 예외, 로깅, 환경설정 등 다양한 인프라 기능을 표준화하고,
각 계층별 책임 분리와 확장성, 일관성, 안정성을 극대화하는 구조로 설계되었습니다.
각 컴포넌트는 명확한 역할과 인터페이스를 갖추고 있으며,
Mermaid.js 다이어그램을 통해 전체 아키텍처와 데이터 흐름을 직관적으로 파악할 수 있습니다.

이 문서는 시스템의 구조적 이해, 유지보수, 확장, 신규 개발 시 필수적인 참조 자료로 활용될 수 있습니다.
각 계층별 세부 구현 및 API, 데이터 모델, 예외/로깅 정책 등은 본 문서를 기반으로 추가 문서화가 가능합니다.', '{}', '2025-06-24 00:25:00.197504 +00:00', null, '2025-06-24 00:25:00.197504 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('d04c7be7-5654-443e-a9b2-09ab5f4b4b4e', e'# MyProject 개요(Overview)

## Introduction

**MyProject**는 대규모 엔터프라이즈 환경(통신, 금융, 공공 등)에서 정산, 청구, 수납, 검증, 통계, 코드관리, 배치, 게시판, 보안 등 복잡한 업무 도메인을 표준화·중앙화·자동화하여, 업무 효율성, 데이터 품질, 시스템 신뢰성, 확장성을 극대화하는 통합 정보계 플랫폼입니다.

본 시스템은 EJB 2.x 기반의 3계층 구조, DAO 패턴, 표준 데이터셋(GauceDataSet) 반환, 보안 필터 계층 등 엔터프라이즈 품질 속성을 전 계층에 내재화한 고응집·저결합 구조로 설계되었습니다. 각 업무 도메인별로 독립적 패키지 구조와 인터페이스 기반 설계, 공통 인프라 계층을 갖추고 있어, 신규 업무/채널/시스템 연동 시 최소한의 개발로 빠른 확장이 가능합니다.

### 전체 시스템 의존성 아키텍처

아래 Mermaid.js 다이어그램은 MyProject의 계층별 주요 역할과 의존성 흐름을 나타냅니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        UI["웹 UI/리포트"]
        Controller["Web Controller"]
        Batch["Batch Scheduler"]
        API["API Gateway"]
        JSP["JSP/Servlet"]
        JRequest["JRequest"]
        JSession["JSession"]
        JFileUpload["JFileUpload"]
        JFileDownload["JFileDownload"]
    end

    subgraph "Controller Layer"
        EJBHome["EJB Home (SBCDA110EHome, SRPT_BCDF440EHome 등)"]
    end

    subgraph "Service Layer"
        Delegate["Delegate/Facade (FCBCDD160E 등)"]
        Remote["EJB Remote (SBCDA110E, SRPT_BCDF440E 등)"]
        Bean["Session Bean (SBCDA110EBean, SRPT_BCDF440EBean 등)"]
    end

    subgraph "Business/Domain Layer"
        DBObjectManager["DBObjectManager"]
        DBObject["DBObject"]
        FileInfo["FileInfo"]
        StructFile["StructFile"]
        JUploadedFile["JUploadedFile"]
    end

    subgraph "Data Access Layer"
        DAO["DAO (DAORPT_BCDF440E 등)"]
        MaxIDGen["MaxIDGen"]
        SeqIDGen["SeqIDGen"]
        SPIDGen["SPIDGen"]
        IDGen["IDGen"]
        DBConnManager["DBConnManager"]
        DBConnPool["DBConnPool"]
        JConnection["JConnection"]
        JPreparedStatement["JPreparedStatement"]
        JResultSet["JResultSet"]
        JStatement["JStatement"]
        DB["DB/외부시스템"]
    end

    subgraph "Utility/Configuration"
        Util["Util"]
        SQLUtil["SQLUtil"]
        JspUtil["JspUtil"]
        DBCodeConverter["DBCodeConverter"]
        StackTraceParser["StackTraceParser"]
        Configuration["Configuration"]
        Gauce["GauceDataSet"]
    end

    UI --> Controller
    Controller --> EJBHome
    Controller --> Delegate
    Delegate --> Remote
    EJBHome --> Remote
    Remote --> Bean
    Bean --> DBObjectManager
    Bean --> DAO
    Bean --> FileInfo
    Bean --> Gauce
    DAO --> DB
    DAO --> Gauce
    DBObjectManager --> DBObject
    DBObject --> IDGen
    DBObject --> FileInfo
    JFileUpload --> FileInfo
    JFileUpload --> StructFile
    JFileUpload --> JUploadedFile
    JFileDownload --> FileInfo

    Bean --> DBConnManager
    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JPreparedStatement
    JConnection --> JStatement
    JPreparedStatement --> JResultSet

    IDGen --> MaxIDGen
    IDGen --> SeqIDGen
    IDGen --> SPIDGen

    Util --> SQLUtil
    Util --> JspUtil
    Util --> DBCodeConverter
    Util --> StackTraceParser
    Util --> Configuration
```
*각 계층별 역할과 데이터/제어 흐름이 명확히 분리되어 있습니다.*

---

## 주요 아키텍처 및 계층별 구조

### 1. Presentation Layer

- **웹 UI, 리포트, API, 배치 등 다양한 채널**에서 표준화된 인터페이스(원격 EJB, GauceDataSet 등)를 통해 서비스 호출
- **JSP/Servlet, JRequest, JSession, JFileUpload, JFileDownload** 등 유틸리티를 통한 입력값 처리, 세션 관리, 파일 입출력 지원

### 2. Controller Layer

- **EJB Home/Delegate/Facade**: 클라이언트 요청을 받아 EJB Session Bean 또는 Delegate로 위임
- **Delegate/Facade**: EJB 원격 호출의 복잡성 은닉, 예외 및 로깅 표준화, 데이터셋 반환 포맷 통일

### 3. Service Layer (EJB Session Bean)

- **Session Bean**: 실제 비즈니스 로직 구현, 트랜잭션/예외/자원 관리, DAO 위임
- **Remote Interface**: 비즈니스 서비스 계약(Contract) 정의
- **Home Interface**: 세션 빈 생성/생명주기 관리

### 4. Data Access Layer

- **DAO**: 업무별 데이터 접근, SQL 실행, 결과 가공, 트랜잭션/예외/자원 관리, 표준 데이터셋 반환
- **IDGen/MaxIDGen/SeqIDGen/SPIDGen**: 다양한 ID 생성 정책 지원
- **DBConnManager/DBConnPool/JConnection/JPreparedStatement/JResultSet**: 커넥션 풀, JDBC 래퍼, 예외 추상화, 로깅, 성능 모니터링

### 5. Business/Domain Layer

- **DBObjectManager/DBObject**: DBMS별 객체 관리, IDGen 전략 주입, 컬럼 주석 조회 등
- **FileInfo/StructFile/JUploadedFile**: 파일 메타데이터 및 업로드 구조 관리

### 6. Utility/Configuration Layer

- **Util/SQLUtil/JspUtil/DBCodeConverter/StackTraceParser**: 범용 데이터 변환, 입력값 검증, 보안, SQL 생성, 문자셋 변환, 예외 스택 파싱 등
- **Configuration**: 환경설정 파일 관리, 설정값 조회/타입 변환/예외 처리
- **GauceDataSet**: 표준 데이터셋 포맷

---

## 도메인 및 업무별 책임 영역

### 주요 도메인

| 도메인                | 주요 책임 및 기능                                                         |
|-----------------------|---------------------------------------------------------------------------|
| 정산/청구/수납/상계   | 데이터 집계, 검증, 이력 관리, 배치 연동, 전체 라이프사이클 관리           |
| 검증/통계/모니터링    | CDR 검증, 라우팅 오류, 경보/알람, 통계 데이터 집계/조회, 결과 저장/알림   |
| 코드/마스터 데이터    | 코드/마스터 데이터 중앙 관리, 표준화된 조회 서비스                        |
| 배치/프로세스/데몬    | 배치 작업, 실행 로그, 상태 모니터링, 데이터 흐름 관리                     |
| 게시판/공지/권한      | 게시글 CRUD, 첨부파일, 답글, 조회수, 권한/그룹/사용자 매핑                |
| 기준정보/정책/요율    | 요율대역, 할인 정책, 임계치, 유효기간, 이력 관리 등                       |
| 보안/입력값 검증      | XSS/SQL Injection 등 입력값 검증, 정책 관리, 요청 흐름 제어, 보안 이벤트 로깅 |

---

## 데이터 흐름 및 시퀀스

### 업무 데이터 저장 시퀀스

```mermaid
sequenceDiagram
    participant WebClient as Web Client
    participant JSP as JSP/Servlet
    participant JRequest as JRequest
    participant SBCDA110EHome as SBCDA110EHome
    participant SBCDA110E as SBCDA110E
    participant SBCDA110EBean as SBCDA110EBean
    participant DBObjectManager as DBObjectManager
    participant DBObject as DBObject
    participant IDGen as IDGen
    participant DBConnManager as DBConnManager
    participant JConnection as JConnection
    participant JPreparedStatement as JPreparedStatement
    participant DB as Database

    WebClient->>JSP: 저장 요청 (폼 데이터)
    JSP->>JRequest: 파라미터 추출/검증
    JSP->>SBCDA110EHome: EJB Home lookup
    JSP->>SBCDA110E: create() 호출
    JSP->>SBCDA110E: saveRecord(GauceDataSet)
    SBCDA110E->>SBCDA110EBean: saveRecord(GauceDataSet)
    SBCDA110EBean->>DBObjectManager: getDBObject()
    DBObjectManager->>DBObject: setIDGen(IDGen)
    SBCDA110EBean->>DBObject: 데이터 저장 호출
    DBObject->>IDGen: getNextID(...)
    DBObject->>DBConnManager: getConnection()
    DBConnManager->>JConnection: 커넥션 획득
    JConnection->>JPreparedStatement: prepareStatement
    JPreparedStatement->>DB: SQL 실행
    DB-->>JPreparedStatement: 실행 결과
    JPreparedStatement-->>JConnection: 결과 반환
    JConnection-->>DBConnManager: 커넥션 반납
    DBObject-->>SBCDA110EBean: 저장 결과
    SBCDA110EBean-->>SBCDA110E: 결과 반환
    SBCDA110E-->>JSP: 결과 반환
    JSP-->>WebClient: 저장 결과 응답
```
*업무 데이터 저장 시, 프레젠테이션 → 컨트롤러 → 세션빈 → DAO/DB 계층으로 흐름이 이어집니다.*

---

## 데이터셋 및 API 요약

### GauceDataSet 컬럼 예시

| 컬럼명           | 타입      | 설명               |
|------------------|----------|--------------------|
| CALL_START       | String   | 집계 기준(월/일)   |
| STD_USE_COUNT    | Decimal  | 표준 사용 건수     |
| MONTH_USE_COUNT  | Decimal  | 월별 사용 건수     |
| STD_USE_TIME     | Decimal  | 표준 사용 시간     |
| MONTH_USE_TIME   | Decimal  | 월별 사용 시간     |
| STD_USE_CHRG     | Decimal  | 표준 사용 요금     |
| MONTH_USE_CHRG   | Decimal  | 월별 사용 요금     |
| STD_USE_DOSU     | Decimal  | 표준 도수          |
| MONTH_USE_DOSU   | Decimal  | 월별 도수          |

### 주요 API 및 파라미터

| 메서드명                | 파라미터 (타입)         | 반환값         | 설명                                 |
|------------------------|------------------------|---------------|--------------------------------------|
| searchRecord1          | String callTypeStd     | GauceDataSet  | 운송사/연도별 집계 조회              |
| searchRecord2          | ...                    | GauceDataSet  | 운송사/월별 집계 조회                |
| saveRecord             | GauceDataSet           | int           | 집계 데이터 등록/수정                |
| searchgraphRecord      | HashMap hmParam        | GauceDataSet  | 통계 데이터 집계 조회                |
| printRecord            | HashMap hmParam        | GauceDataSet  | 리포트용 데이터셋(Stub, 확장 가능)   |

#### searchgraphRecord 파라미터 예시

| 파라미터명         | 타입     | 설명                       |
|--------------------|----------|----------------------------|
| settle_carrier     | String   | 정산 사업자                |
| clg_carrier        | String   | 발신 사업자                |
| cld_carrier        | String   | 착신 사업자                |
| services           | String   | 서비스 코드                |
| chrg_item          | String   | 과금 항목                  |
| interval           | String   | 집계 단위(월/일)           |
| gubun              | String   | 검증/정산 구분             |
| call_type          | String   | 통화 유형                  |
| from_month         | String   | 조회 시작 월/일            |
| to_month           | String   | 조회 종료 월/일            |

---

## 품질 속성 및 확장성

| 항목                   | 설명                                                                                   |
|------------------------|----------------------------------------------------------------------------------------|
| 관심사 분리            | Controller, Service, DAO, Infra 등 역할별로 명확히 분리                                |
| 표준화된 데이터셋      | GauceDataSet 기반으로 프론트엔드/리포트 시스템과의 연동 표준화                         |
| 동적 쿼리/파라미터화   | 다양한 통계 조건에 따라 동적으로 쿼리 생성 및 파라미터 바인딩                         |
| 트랜잭션/예외 관리      | EJB 컨테이너 및 JEJBException 등으로 안정적 트랜잭션/예외 처리                         |
| 확장성                 | Stub 메서드, HashMap 파라미터 등으로 향후 기능/조건/포맷 확장 용이                    |
| 분산 환경 지원         | EJBObject 상속, RemoteException 등으로 분산 시스템에서의 안정적 서비스 제공            |
| 타입 안전성 강화       | HashMap 파라미터 → DTO(전용 파라미터 객체)로 변경하여 컴파일 타임 타입 체크 강화        |
| 데이터셋 포맷 다양화   | GauceDataSet 외 JSON, DTO 등 다양한 포맷 지원                                          |
| 로깅/모니터링 강화     | 서비스 호출, 쿼리 성능, 예외 발생 등에 대한 로깅 및 모니터링 체계 강화                 |
| 테스트 용이성 강화     | 인터페이스 기반 설계, Mock 객체 주입 등으로 단위 테스트 자동화 가능                    |

---

## 결론

MyProject는 대규모 엔터프라이즈 환경에서 복잡한 업무 도메인을 표준화·중앙화·자동화하여,
업무 효율성, 데이터 품질, 시스템 신뢰성, 확장성, 운영/감사/보안까지 모두 충족하는 통합 정보계 플랫폼입니다.

- **아키텍처적으로**: EJB 2.x 기반 3계층 구조, DAO 패턴, 표준 데이터셋 반환, 보안 필터 계층 등 고응집·저결합 구조 실현
- **도메인적으로**: 각 업무별 독립성과 공통 코드/마스터 데이터/보안/운영 등 중앙 허브 패키지 보유
- **기술적으로**: 엔터프라이즈 환경에서 검증된 기술과 설계 원칙 충실 적용
- **확장성/유지보수성**: 도메인별 고응집 패키지, 인터페이스 기반 설계, 표준 데이터셋, 관심사 분리 등으로 업무 변화, 시스템 확장, 기술 진화에 유연하게 대응

향후 DI/DTO/ORM/RESTful API 등 현대적 아키텍처 도입, 프레임워크/DBMS 독립성 강화, 테스트 자동화, 로깅/보안/운영 품질 고도화, 코드 중복 제거, 정책 외부화 등을 통해
더욱 견고하고 유연한 엔터프라이즈 플랫폼으로 진화할 수 있습니다.

**MyProject는 도메인별 고응집·저결합 구조, 표준화된 데이터셋, 엔터프라이즈 품질 내재화,
확장성·유지보수성·운영성·보안성까지 모두 고려한 통합 정보계 시스템의 모범적 설계입니다.**', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('475ab0f3-465a-4df3-9111-24a2b9a4fa34', e'# 공통기반 및 유틸리티

---

## 소개

**공통기반 및 유틸리티**는 ICBS 및 대규모 엔터프라이즈 시스템에서 반복적으로 사용되는 데이터 처리, 암호화, 인코딩, 파일 입출력, 세션/요청/응답 관리, 로깅, 환경설정, 데이터 변환, 입력 검증 등 핵심 인프라 기능을 제공합니다.
이 모듈은 컨트롤러, 서비스, DAO, 프레젠테이션 등 다양한 계층에서 재사용되며,
- 코드 중복 최소화
- 표준화 및 일관성 보장
- 보안 및 품질 강화
- 업무 생산성 향상
을 목표로 설계되었습니다.

아래 아키텍처 다이어그램은 전체 시스템 내 공통/유틸리티 모듈의 의존성 흐름을 나타냅니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        Controller["Controller (Servlet/JSP)"]
        JSPUtil["JspUtil"]
        ScreenMgr["ScreenManager"]
    end
    subgraph "Controller Layer"
        Ctrl["Web Controller"]
    end
    subgraph "Service Layer"
        Service["Service/Business Logic"]
    end
    subgraph "Business Layer"
        CodeMgr["CodeManager"]
        Util["ICBSUtil/Util"]
        SQLUtil["SQLUtil"]
    end
    subgraph "Data Access Layer"
        DAO["DAO/Repository"]
        DBObjMgr["DBObjectManager"]
        DBObj["DBObject_ORA/MSSQL"]
        DBConnMgr["DBConnManager"]
        JConn["JConnection"]
        JStmt["JStatement"]
        JPrepStmt["JPreparedStatement"]
        JResSet["JResultSet"]
        DBCodeConv["DBCodeConverter"]
    end
    subgraph "Domain Layer"
        DomainObj["Domain/VO/DTO"]
    end
    subgraph "Common & Utility Layer"
        Encoder["ICBSEncoder"]
        AES["AES256Util"]
        Base64["Base64Util"]
        Logger["FileLogger/FileLoggerIF/Log/LogWriter"]
        File["FileLoader/JFileUpload/JFileDownload/FileInfo/StructFile"]
        Session["ICBSSession/ICBSStructSession/JSession"]
        Request["ICBSRequest/JRequest"]
        ComENT["ComENT"]
    end
    subgraph "Configuration Layer"
        Config["Configuration/JProperties/Const"]
    end

    Controller --> Util
    Controller --> Encoder
    Controller --> AES
    Controller --> Base64
    Controller --> Logger
    Controller --> File
    Controller --> Session
    Controller --> Request
    Controller --> ComENT
    Controller --> DomainObj
    Controller --> Config

    JSPUtil --> Util
    JSPUtil --> CodeMgr
    JSPUtil --> ScreenMgr

    Ctrl --> Service
    Service --> Util
    Service --> SQLUtil
    Service --> CodeMgr
    Service --> Logger
    Service --> File
    Service --> Session
    Service --> Request
    Service --> DomainObj
    Service --> Config

    DAO --> Util
    DAO --> Logger
    DAO --> File
    DAO --> Config

    Util --> AES
    Util --> Encoder
    Util --> Base64
    Util --> Logger
    Util --> Config

    SQLUtil --> Util
    SQLUtil --> Config
    SQLUtil --> Const
    SQLUtil --> JPrepStmt

    CodeMgr --> Config
    CodeMgr --> DBConnMgr
    CodeMgr --> JStmt
    CodeMgr --> JResSet

    File --> FileInfo
    File --> StructFile

    Session --> ICBSStructSession

    Request --> ComENT

    Config --> Logger
    Config --> File
    Config --> Session
    Config --> Request
    Config --> Util
    Config --> Const
```

---

## 1. 유틸리티 계층 구조 및 주요 컴포넌트

### 1.1. 전체 구조

| 분류         | 주요 클래스/인터페이스                | 설명                                      |
|--------------|--------------------------------------|-------------------------------------------|
| 범용 유틸리티 | ICBSUtil, Util, ICBSEncoder, AES256Util, Base64Util | 날짜/문자열/숫자/암호화/인코딩 등 범용 기능 |
| 로깅         | FileLogger, FileLoggerIF, Log, LogWriter | 파일/콘솔 기반 로깅, 감사/운영 로그 기록    |
| 파일처리     | FileLoader, JFileUpload, JFileDownload, FileInfo, StructFile | 파일 업로드/다운로드/메타데이터 관리      |
| 세션/요청    | ICBSSession, ICBSStructSession, JSession, ICBSRequest, JRequest | 세션/요청/파라미터/속성/매핑 관리         |
| 데이터 구조  | ComENT, StructFile, FileInfo         | 파라미터/파일 등 데이터 전달 객체(VO/DTO)  |
| 환경설정     | Configuration, JProperties, Const    | 환경설정 파일, 상수 관리                   |
| 코드/화면    | CodeManager, ScreenManager, PagedList| 코드 테이블, 화면 정의, 페이징 관리        |

---

## 2. 주요 컴포넌트 상세

### 2.1. 범용 유틸리티

#### ICBSUtil / Util

- 날짜/시간, 문자열, 숫자, 한글 변환, 암호화, SQL 인젝션 방지 등 범용 기능 제공
- 정적 메서드로 어디서든 호출 가능

| 메서드명             | 설명                                 |
|----------------------|--------------------------------------|
| urlEncodePartial     | URL 구조 유지 부분 인코딩            |
| getNextMonth         | 기준월로부터 N개월 후 월 계산        |
| makeXDigit           | 숫자를 지정 자릿수 문자열로 변환     |
| encodingData         | SHA-1 해시값 생성                    |
| changeChar           | 문자열 다중 치환                     |
| ceiling/round        | 반올림/올림                          |
| getSQLTimestamp      | 문자열→Timestamp 변환                |
| validateInput        | SQL 인젝션 방지(실효성은 미흡)        |
| toInt/toLong/...     | 문자열→숫자 변환                     |
| formatNum/formatDate | 숫자/날짜 포맷팅                     |
| split/replaceString  | 문자열 분할/치환                     |

**코드 예시**
```java
public static int toInt(String value) throws UtilException {
    if(value == null || value.equals("")) return 0;
    value = checkValidNumberString(value);
    try {
        return Integer.parseInt(value.trim());
    } catch(NumberFormatException ex) {
        Log.err.println(ex);
        throw new UtilException("Illegal argument \'value\': " + ex.getMessage());
    }
}
```

#### ICBSEncoder

- 커스텀 인코딩/디코딩(난독화, 중복 인코딩 관리)

| 메서드명      | 설명                       |
|---------------|----------------------------|
| encode        | 커스텀 인코딩              |
| decode        | 커스텀 디코딩              |
| isURLEncoded  | 커스텀 인코딩 여부 판별    |

#### AES256Util / AES256Util2

- AES-256 대칭키 암호화/복호화 지원, 환경설정 기반 동적 초기화

| 메서드명           | 설명                         |
|--------------------|------------------------------|
| getAESEncrypt      | AES-256 암호화(Base64 반환)  |
| getAESDecrypt      | AES-256 복호화               |
| setKeyStr          | (AES256Util2) 키 복원        |
| getPropetyRead     | (AES256Util2) 환경설정 로딩  |

**코드 예시**
```java
public String getAESEncrypt(String str) throws ... {
    Cipher c = Cipher.getInstance(TRANSFORMATION);
    c.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(iv.getBytes()));
    byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
    BASE64Encoder encoder = new BASE64Encoder();
    String enStr = encoder.encode(encrypted);
    return enStr;
}
```

#### Base64Util

- 문자열 Base64 인코딩/디코딩/Reverse 변형

| 메서드명             | 설명                       |
|----------------------|----------------------------|
| getBase64EncodStr    | Base64 인코딩              |
| getBase64DecodStr    | Base64 디코딩              |
| getBase64ReverseStr  | 44자 Base64 문자열 변형    |

---

### 2.2. 입력값 검증 및 보안 유틸리티

- XSS/SQL Injection/OS Command Injection/HTTP Response Splitting 방지
- CheckDecimal, CheckLength, CheckIP, checkDate 등 기본 유효성 검사
- 파라미터별 맞춤 검증(checkParam)

| 함수명             | 설명                                  |
|-------------------|--------------------------------------|
| isNotValidXSS     | XSS 공격 문자열 포함 여부 검사         |
| isNotValidSQL     | SQL Injection 문자열 포함 여부 검사    |
| isNotOsCommandValid | OS 명령어 인젝션 문자열 검사         |
| isHTTP_CWE113     | HTTP 응답분할(CRLF) 문자열 검사       |
| checkParam        | 파라미터별 화이트리스트/정규식 검증   |

**코드 예시**
```java
public static boolean isNotValidXSS(String paramValue) {
    if (paramValue == null || paramValue.trim().equals("")) return false;
    Matcher m = bp.matcher(paramValue);
    return m.find();
}
```

---

### 2.3. 환경/설정/DB 연동 유틸리티

- 프로퍼티 파일 로딩(getPropertiesFromFile, getProp)
- DB 권한 체크(checkUserGrantMenu, checkUserGrantMenuID)
- 객체-맵핑/DB 문자셋 변환(mapToObject, convertObjectToDBData)

| 함수명                  | 설명                              |
|------------------------|----------------------------------|
| getPropertiesFromFile  | 환경 파일로부터 JProperties 반환  |
| getProp                | 환경 프로퍼티 값 조회             |
| checkUserGrantMenu     | 메뉴 접근 권한 체크(DB 연동)      |
| mapToObject            | 객체 매핑(필드명 기반)            |
| convertObjectToDBData  | 객체 내 문자열을 DB 문자셋으로 변환|

**코드 예시**
```java
public static JProperties getPropertiesFromFile(String pathName) {
    if(pathName == null || pathName.equals(""))
        throw new UtilException("Parameter \'pathName\' can not be null or \\"\\".");
    return getPropertiesFromFile(new File(pathName));
}
```

---

### 2.4. SQL 유틸리티

- 검색 조건 파싱/인코딩/디코딩(encode, decode, parse)
- 동적 SQL 생성(makeSearchSQL, makeSearchSQLPrepared)
- PreparedStatement 파라미터 바인딩(setParameter)

| 함수명                  | 설명                              |
|------------------------|----------------------------------|
| encode/decode          | 조건 문자열 인코딩/디코딩         |
| parse                  | 조건 문자열 파싱                  |
| makeSearchSQL          | 동적 WHERE절 생성                |
| makeSearchSQLPrepared  | PreparedStatement용 WHERE절 생성 |
| setParameter           | PreparedStatement 파라미터 바인딩 |

---

### 2.5. 프레젠테이션/화면 유틸리티

- URL 인코딩/디코딩(urlEncode, urlDecode)
- HTML 안전 변환(convertToPrintableHTML)
- 콤보박스/페이징 UI 동적 생성(genComboBox, getPageAnchor, getPageAnchorMHTML)

| 함수명                  | 설명                              |
|------------------------|----------------------------------|
| urlEncode/urlDecode    | URL 인코딩/디코딩                 |
| convertToPrintableHTML | HTML 안전 문자열 변환              |
| genComboBox            | 콤보박스(HTML select) 동적 생성   |
| getPageAnchor          | 페이징 네비게이션 바 생성          |
| getPageAnchorMHTML     | 모바일용 페이징 네비게이션 생성    |

---

### 2.6. 로깅

#### FileLoggerIF

- 로그 코드, 파일 경로/명 등 상수 정의

| 상수명             | 설명                       |
|--------------------|----------------------------|
| LOGIN_FAILED       | 로그인 실패                |
| ACTION_OK          | CRUD 성공                  |
| logFilePath        | 로그 파일 경로             |
| logFileName        | 로그 파일명                |
| logFileExt         | 로그 파일 확장자           |

#### FileLogger / Log / LogWriter

- 파일/콘솔 기반 로그 기록(일반, DML, SQL)
- 날짜별 파일 자동 생성/로테이션, 스레드 안전성

| 메서드명           | 설명                       |
|--------------------|----------------------------|
| writeLog           | 시스템 로그 기록           |
| writeDMLLog        | DML 로그 기록              |
| makeNewFile        | 새 로그 파일 생성          |
| closeFileObject    | 파일 스트림 해제           |

**코드 예시**
```java
public static synchronized void writeLog(String strLogType, String userid, String username, String resource) {
    logFileCheck();
    bw.write(strLogType+","+getLogCurrentTime(",") + "," + userid + "," + username + "," + resource + "\\r");
    bw.flush();
}
```

---

### 2.7. 파일 처리

- FileLoader: HTTP 파일 다운로드/미리보기 서블릿
- JFileUpload/JFileDownload: 멀티파트 파일 업로드/다운로드 처리
- FileInfo, StructFile: 파일 메타데이터(경로, 이름, 크기, 확장자 등) 관리용 VO/DTO

---

### 2.8. 세션/요청/파라미터 관리

- ICBSSession/JSession: HttpSession 래핑, 세션 유효성 검사, 속성 관리, 무효화, 타임아웃 등
- ICBSStructSession: 사용자 세션 상태/인증/OTP 등 통합 관리, 세션 라이프사이클 이벤트로 DB 상태 동기화
- ICBSRequest/JRequest: HttpServletRequest 래핑, 파라미터 인코딩, 파라미터→객체 매핑, 세션 관리, 속성 관리 등

**코드 예시**
```java
public Object mapToObject(Class target) throws JServletException {
    Object obj = target.newInstance();
    Enumeration enu = getParameterNames();
    Method[] methods = target.getMethods();
    while(enu.hasMoreElements()) {
        String requestField = (String)enu.nextElement();
        String requestFieldValue = getParameter(requestField);
        // setter 탐색 및 값 할당
        // ...
    }
    return obj;
}
```

---

### 2.9. 데이터 전달 객체

- ComENT: 대량 파라미터 전달용 VO(36개 String 필드)
- StructFile: 파일 업로드/다운로드용 구조체(경로, 파일명, 필드명)
- FileInfo: 파일 메타데이터 관리(파일ID, 이름, 경로, 크기 등)

---

### 2.10. 예외 계층

- UtilException, DBException, JException, JEJBException, JMailException, ConfigurationException 등
- 각 계층별/도메인별 예외를 명확히 구분하여, 예외 흐름의 일관성 및 진단성 강화

```mermaid
classDiagram
    class Exception
    class JException
    class UtilException
    class DBException
    class JEJBException
    class JMailException
    class ConfigurationException

    Exception <|-- JException
    JException <|-- UtilException
    JException <|-- DBException
    JException <|-- JEJBException
    JException <|-- JMailException
    JException <|-- ConfigurationException
```

---

## 3. 대표적 데이터 흐름 및 아키텍처 시퀀스

### 3.1. 컨트롤러-서비스-DAO-유틸리티-로깅 호출 흐름

```mermaid
graph TD
    subgraph "Controller Layer"
        Controller["FileDownloadServlet"]
    end
    subgraph "Service Layer"
        FileService["FileService"]
    end
    subgraph "Data Access Layer"
        FileDAO["FileDAO"]
    end
    subgraph "Common & Utility Layer"
        Util["ICBSUtil"]
        Logger["FileLogger"]
        Session["ICBSSession"]
    end
    Controller --> FileService
    FileService --> FileDAO
    FileService --> Util
    FileService --> Logger
    Controller --> Session
```
**설명:**
- 컨트롤러가 요청을 받아 서비스 호출
- 서비스는 DAO, 유틸리티, 로깅 등 공통 모듈 활용
- 세션/요청/파일 등은 공통 객체로 관리

---

### 3.2. 파일 다운로드 시퀀스 다이어그램

```mermaid
sequenceDiagram
    participant User as 사용자
    participant Controller as FileDownloadServlet
    participant Session as ICBSSession
    participant FileService as FileService
    participant FileDAO as FileDAO
    participant Logger as FileLogger

    User ->> Controller: 파일 다운로드 요청
    Controller ->> Session: 세션 유효성 검사 +
    Controller ->> FileService: 파일 다운로드 처리 요청 +
    FileService ->> FileDAO: 파일 메타데이터 조회 +
    FileDAO -->> FileService: 파일 정보 반환 -
    FileService ->> Logger: 다운로드 이력 기록 +
    FileService -->> Controller: 파일 스트림 반환 -
    Controller -->> User: 파일 응답
    Note over Controller,FileService: 오류 발생 시 Logger에 에러 기록
```

---

## 4. 주요 데이터 구조/설정/상수 요약

### 4.1. FileLoggerIF 상수

| 상수명             | 값/설명                        |
|--------------------|-------------------------------|
| LOGIN_FAILED       | "LOGIN_FAILED"                |
| ACTION_OK          | "ACTION_OK"                   |
| logFilePath        | "D:\\\\Project\\\\SystemLogs\\\\icbs\\\\" |
| logFileName        | "serverLog"                   |
| logFileExt         | ".csv"                        |

### 4.2. ICBSStructSession 주요 필드

| 필드명            | 타입     | 설명                  |
|-------------------|----------|-----------------------|
| user_id           | String   | 사용자 ID             |
| user_name         | String   | 사용자명              |
| user_ip           | String   | 사용자 IP             |
| org               | String   | 조직                  |
| level             | String   | 등급                  |
| lastlogindate     | String   | 최종 로그인 일자       |
| strOTP            | String   | OTP                   |
| strOtpResult      | String   | OTP 인증 결과         |

---

## 5. 대표 코드 스니펫

### 5.1. ICBSRequest의 파라미터→객체 매핑

```java
public Object mapToObject(Class target) throws JServletException {
    Object obj = target.newInstance();
    Enumeration enu = getParameterNames();
    Method[] methods = target.getMethods();
    while(enu.hasMoreElements()) {
        String requestField = (String)enu.nextElement();
        String requestFieldValue = getParameter(requestField);
        // setter 탐색 및 값 할당
        // ...
    }
    return obj;
}
```

### 5.2. FileLogger의 로그 기록

```java
public static synchronized void writeLog(String strLogType, String userid, String username, String resource) {
    logFileCheck();
    bw.write(strLogType+","+getLogCurrentTime(",") + "," + userid + "," + username + "," + resource + "\\r");
    bw.flush();
}
```

### 5.3. AES256Util의 암호화/복호화

```java
public String getAESEncrypt(String str) throws ... {
    Cipher c = Cipher.getInstance(TRANSFORMATION);
    c.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(iv.getBytes()));
    byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
    BASE64Encoder encoder = new BASE64Encoder();
    String enStr = encoder.encode(encrypted);
    return enStr;
}
```

---

## 6. 데이터 구조/파라미터/설정 요약 표

### 6.1. ICBSStructSession 필드 요약

| 필드명           | 타입    | 설명           |
|------------------|---------|----------------|
| user_id          | String  | 사용자 ID      |
| user_name        | String  | 사용자명       |
| user_ip          | String  | 사용자 IP      |
| org              | String  | 조직           |
| level            | String  | 등급           |
| lastlogindate    | String  | 최종 로그인일  |
| strOTP           | String  | OTP            |
| strOtpResult     | String  | OTP 인증 결과  |

### 6.2. FileLoggerIF 로그 코드

| 코드명             | 설명           |
|--------------------|----------------|
| LOGIN_FAILED       | 로그인 실패    |
| ACTION_DENIED      | CRUD 거부      |
| SYSTEM_ERROR       | 시스템 에러    |
| ACCESS_DENIED      | 접근 실패      |
| ACTION_OK          | CRUD 성공      |
| LOGIN_SUCCESS      | 로그인 성공    |
| LOGOUT_SUCCESS     | 로그아웃 성공  |
| ACCESS_CONTENTS    | 컨텐츠 접근    |
| DML_DURATION       | DML 퍼포먼스   |

---

## 7. 결론

**공통기반 및 유틸리티**는
- 시스템 전반의 **표준화·재사용성·일관성·보안성**을 책임지는 핵심 인프라 계층입니다.
- 날짜/문자열/암호화/인코딩/파일/세션/요청/로깅 등
  다양한 범용 기능을 제공하여,
  각 계층(Controller, Service, DAO, Presentation 등)에서
  **중복 없는 품질 높은 개발**을 가능하게 합니다.

**아키텍처적으로**
- 컨트롤러, 서비스, DAO, 프레젠테이션 등 모든 계층에서
  공통 모듈을 통해 데이터 처리, 보안, 로깅, 파일, 세션 등
  핵심 기능을 일관되게 적용할 수 있습니다.

**향후 발전 방향**
- 표준화 강화, 보안/유효성 검증 고도화,
- 프레임워크/환경설정 외부화,
- 테스트/로깅/모니터링 체계화,
- DTO/JSON 등 다양한 데이터 포맷 지원,
- 현대적 아키텍처(ORM, DI 등)와의 연계
등으로 더욱 견고하고 유연한 인프라 계층으로 발전할 수 있습니다.

---

**요약**
공통기반 및 유틸리티는
- ICBS 시스템의 품질, 생산성, 보안, 유지보수성을
  획기적으로 향상시키는 **핵심 인프라 계층**입니다.
- 각 계층에서 반복되는 데이터 처리, 암호화, 인코딩, 파일, 세션, 요청, 로깅 등
  모든 범용 기능을 표준화·중앙화하여
  **대규모 업무 시스템의 신뢰성과 확장성**을 뒷받침합니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('fc97e3f2-fa63-4c93-a8e9-293025121bbc', e'# 공통 및 유틸리티 기능 모듈

---

## 소개

**공통 및 유틸리티 기능 모듈**은 ICBS 시스템 전반에서 반복적으로 사용되는 데이터 처리, 암호화, 인코딩, 파일 입출력, 세션/요청/응답 관리, 로깅, 각종 업무 유틸리티 등 핵심 인프라 기능을 제공합니다.
이 모듈은 컨트롤러, 서비스, DAO, 프레젠테이션 등 다양한 계층에서 재사용되며,
- **코드 중복 최소화**
- **표준화 및 일관성 보장**
- **보안 및 품질 강화**
- **업무 생산성 향상**
을 목표로 설계되었습니다.

아래 아키텍처 다이어그램은 전체 시스템 내 공통/유틸리티 모듈의 의존성 흐름을 나타냅니다.

**아키텍처 다이어그램 설명:**
- Presentation, Business, Data, Domain, Configuration 등 주요 레이어를 중심으로,
- 공통/유틸리티 모듈이 각 계층에 어떻게 연결되는지 시각화하였습니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        Controller["Controller (Servlet/JSP)"]
    end
    subgraph "Business Layer"
        Service["Service/Business Logic"]
    end
    subgraph "Data Access Layer"
        DAO["DAO (Data Access Object)"]
    end
    subgraph "Domain Layer"
        DomainObj["Domain/VO/DTO"]
    end
    subgraph "Common & Utility Layer"
        Util["ICBSUtil\\nICBSEncoder\\nAES256Util\\nBase64Util"]
        Logger["FileLogger\\nFileLoggerIF"]
        File["FileLoader\\nJFileUpload\\nJFileDownload"]
        Session["ICBSSession\\nICBSStructSession\\nJSession"]
        Request["ICBSRequest\\nJRequest"]
        ComENT["ComENT\\nStructFile\\nFileInfo"]
    end
    subgraph "Configuration Layer"
        Config["Configuration"]
    end

    Controller -->|사용자 요청/응답| Request
    Controller -->|세션 관리| Session
    Controller -->|파일 업로드/다운로드| File
    Controller -->|로깅| Logger
    Controller -->|공통 유틸리티| Util
    Controller -->|도메인 객체| DomainObj
    Controller -->|설정| Config

    Service -->|비즈니스 처리| Util
    Service -->|로깅| Logger
    Service -->|파일 처리| File
    Service -->|세션/요청| Session
    Service -->|도메인 객체| DomainObj
    Service -->|설정| Config

    DAO -->|데이터 변환| Util
    DAO -->|로깅| Logger
    DAO -->|파일 처리| File
    DAO -->|설정| Config

    Request -->|파라미터 매핑| ComENT
    Session -->|사용자 정보| ICBSStructSession
    File -->|파일 메타| FileInfo
    File -->|파일 구조| StructFile

    Util -->|암호화/인코딩| AES256Util
    Util -->|인코딩| ICBSEncoder
    Util -->|Base64| Base64Util

    Logger -->|상수| FileLoggerIF

    Config -->|환경설정| Util
    Config -->|환경설정| Logger
    Config -->|환경설정| File
    Config -->|환경설정| Session
    Config -->|환경설정| Request
```

---

## 1. 유틸리티 계층 구조 및 주요 컴포넌트

### 1.1. 전체 구조

공통 및 유틸리티 기능 모듈은 다음과 같이 분류됩니다.

| 분류         | 주요 클래스/인터페이스                | 설명                                      |
|--------------|--------------------------------------|-------------------------------------------|
| 유틸리티     | ICBSUtil, ICBSEncoder, AES256Util, Base64Util | 날짜/문자열/숫자/암호화/인코딩 등 범용 기능 |
| 로깅         | FileLogger, FileLoggerIF             | 파일 기반 로깅, 감사/운영 로그 기록        |
| 파일처리     | FileLoader, JFileUpload, JFileDownload, FileInfo, StructFile | 파일 업로드/다운로드/메타데이터 관리      |
| 세션/요청    | ICBSSession, ICBSStructSession, JSession, ICBSRequest, JRequest | 세션/요청/파라미터/속성/매핑 관리         |
| 데이터 구조  | ComENT, StructFile, FileInfo         | 파라미터/파일 등 데이터 전달 객체(VO/DTO)  |

---

## 2. 주요 컴포넌트 상세

### 2.1. 범용 유틸리티(ICBSUtil, ICBSEncoder, AES256Util, Base64Util)

#### 2.1.1. ICBSUtil

- 날짜/시간, 문자열, 숫자, 한글 변환, 암호화, SQL 인젝션 방지 등 범용 기능 제공
- 정적 메서드로 어디서든 호출 가능

**주요 메서드 요약**

| 메서드명             | 설명                                 |
|----------------------|--------------------------------------|
| urlEncodePartial     | URL 구조 유지 부분 인코딩            |
| getNextMonth         | 기준월로부터 N개월 후 월 계산        |
| getMonthDuration     | 두 월 사이 개월 수 계산              |
| makeXDigit           | 숫자를 지정 자릿수 문자열로 변환     |
| makeKorNum/Unit/String | 숫자→한글 변환                     |
| encodingData         | SHA-1 해시값 생성                    |
| changeChar           | 문자열 다중 치환                     |
| ceiling/round        | 반올림/올림                          |
| getSQLTimestamp      | 문자열→Timestamp 변환                |
| getTitle/getItemTitle| 문자열 길이 제한/요약                |
| validateInput        | SQL 인젝션 방지(실효성은 미흡)        |

**코드 예시**
```java
public static String getNextMonth(String currMonth, int duration, String format) {
    if (format == null || format.equals("")) {
        format = "yyyyMM";
    }
    GregorianCalendar calendar = new GregorianCalendar();
    calendar.set(Calendar.YEAR, Util.toInt(currMonth.substring(0, 4)));
    calendar.set(Calendar.MONTH, Util.toInt(currMonth.substring(4, 6)) - 1);
    calendar.set(Calendar.DATE, 1);
    calendar.add(Calendar.MONTH, duration);
    return new SimpleDateFormat(format).format(calendar.getTime());
}
```

#### 2.1.2. ICBSEncoder

- 커스텀 인코딩/디코딩(난독화, 중복 인코딩 관리)
- "0^%*)" 프리픽스, 인코딩 횟수 포함

**주요 메서드**

| 메서드명      | 설명                       |
|---------------|----------------------------|
| encode        | 커스텀 인코딩              |
| decode        | 커스텀 디코딩              |
| isURLEncoded  | 커스텀 인코딩 여부 판별    |

**코드 예시**
```java
public static String encode( String s ) {
    int encodeCnt = 0;
    if ( s.substring(0,5).equals("0^%*)") ) {
        encodeCnt = Integer.parseInt(s.substring(5,6));
        s = s.substring(6);
    }
    encodeCnt++;
    // ... (생략)
    return "0^%*)" + new Integer(encodeCnt).toString() + sb.toString();
}
```

#### 2.1.3. AES256Util / AES256Util2

- AES-256 대칭키 암호화/복호화 지원
- 키/IV 관리, 환경설정 기반 동적 초기화, Base64 인코딩

**주요 메서드**

| 메서드명           | 설명                         |
|--------------------|------------------------------|
| getAESEncrypt      | AES-256 암호화(Base64 반환)  |
| getAESDecrypt      | AES-256 복호화               |
| setKeyStr          | (AES256Util2) 키 복원        |
| getPropetyRead     | (AES256Util2) 환경설정 로딩  |

**코드 예시**
```java
public String getAESEncrypt(String str) throws ... {
    Cipher c = Cipher.getInstance(TRANSFORMATION); // AES/CBC/PKCS5Padding
    c.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(iv.getBytes()));
    byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
    BASE64Encoder encoder = new BASE64Encoder();
    String enStr = encoder.encode(encrypted);
    return enStr;
}
```

#### 2.1.4. Base64Util

- 문자열 Base64 인코딩/디코딩/Reverse 변형

| 메서드명             | 설명                       |
|----------------------|----------------------------|
| getBase64EncodStr    | Base64 인코딩              |
| getBase64DecodStr    | Base64 디코딩              |
| getBase64ReverseStr  | 44자 Base64 문자열 변형    |

---

### 2.2. 로깅(FileLogger, FileLoggerIF)

#### 2.2.1. FileLoggerIF

- 로그 코드, 파일 경로/명 등 상수 정의

| 상수명             | 설명                       |
|--------------------|----------------------------|
| LOGIN_FAILED       | 로그인 실패                |
| ACTION_OK          | CRUD 성공                  |
| logFilePath        | 로그 파일 경로             |
| logFileName        | 로그 파일명                |
| logFileExt         | 로그 파일 확장자           |

#### 2.2.2. FileLogger

- 파일 기반 로그 기록(일반, DML, SQL)
- 날짜별 파일 자동 생성/로테이션, 스레드 안전성

| 메서드명           | 설명                       |
|--------------------|----------------------------|
| writeLog           | 시스템 로그 기록           |
| writeDMLLog        | DML 로그 기록              |
| makeNewFile        | 새 로그 파일 생성          |
| closeFileObject    | 파일 스트림 해제           |

**코드 예시**
```java
public static synchronized void writeLog(String strLogType, String userid, String username, String resource) {
    logFileCheck();
    bw.write(strLogType+","+getLogCurrentTime(",") + "," + userid + "," + username + "," + resource + "\\r");
    bw.flush();
}
```

---

### 2.3. 파일 처리(FileLoader, JFileUpload, JFileDownload, FileInfo, StructFile)

#### 2.3.1. FileLoader

- HTTP 파일 다운로드/미리보기 서블릿
- 파일 경로 관리, MIME 타입 처리, 에러 안내

#### 2.3.2. JFileUpload / JFileDownload

- 멀티파트 파일 업로드/다운로드 처리
- 파일 저장, 파라미터/파일 필드 분리, 파일명/경로 관리

#### 2.3.3. FileInfo, StructFile

- 파일 메타데이터(경로, 이름, 크기, 확장자 등) 관리용 VO/DTO

---

### 2.4. 세션/요청/파라미터 관리(ICBSSession, ICBSStructSession, JSession, ICBSRequest, JRequest)

#### 2.4.1. ICBSSession / JSession

- HttpSession 래핑, 세션 유효성 검사, 속성 관리, 무효화, 타임아웃 등 세션 라이프사이클 제어

#### 2.4.2. ICBSStructSession

- 사용자 세션 상태/인증/OTP 등 통합 관리
- 세션 라이프사이클 이벤트(valueBound/valueUnbound)로 DB 상태 동기화

#### 2.4.3. ICBSRequest / JRequest

- HttpServletRequest 래핑, 파라미터 인코딩, 파라미터→객체 매핑, 세션 관리, 속성 관리 등
- mapToObject로 폼 파라미터→DTO 자동 매핑

---

### 2.5. 데이터 전달 객체(ComENT, StructFile, FileInfo)

- ComENT: 대량 파라미터 전달용 VO(36개 String 필드)
- StructFile: 파일 업로드/다운로드용 구조체(경로, 파일명, 필드명)
- FileInfo: 파일 메타데이터 관리(파일ID, 이름, 경로, 크기 등)

---

## 3. 대표적 데이터 흐름 및 아키텍처 시퀀스

### 3.1. 컨트롤러-서비스-DAO-유틸리티-로깅 호출 흐름

```mermaid
graph TD
    subgraph "Controller Layer"
        Controller["FileDownloadServlet"]
    end
    subgraph "Service Layer"
        FileService["FileService"]
    end
    subgraph "Data Access Layer"
        FileDAO["FileDAO"]
    end
    subgraph "Common & Utility Layer"
        Util["ICBSUtil"]
        Logger["FileLogger"]
        Session["ICBSSession"]
    end
    Controller --> FileService
    FileService --> FileDAO
    FileService --> Util
    FileService --> Logger
    Controller --> Session
```
**설명:**
- 컨트롤러가 요청을 받아 서비스 호출
- 서비스는 DAO, 유틸리티, 로깅 등 공통 모듈 활용
- 세션/요청/파일 등은 공통 객체로 관리

---

### 3.2. 파일 다운로드 시퀀스 다이어그램

```mermaid
sequenceDiagram
    participant User as 사용자
    participant Controller as FileDownloadServlet
    participant Session as ICBSSession
    participant FileService as FileService
    participant FileDAO as FileDAO
    participant Logger as FileLogger

    User ->> Controller: 파일 다운로드 요청
    Controller ->> Session: 세션 유효성 검사 +
    Controller ->> FileService: 파일 다운로드 처리 요청 +
    FileService ->> FileDAO: 파일 메타데이터 조회 +
    FileDAO -->> FileService: 파일 정보 반환 -
    FileService ->> Logger: 다운로드 이력 기록 +
    FileService -->> Controller: 파일 스트림 반환 -
    Controller -->> User: 파일 응답
    Note over Controller,FileService: 오류 발생 시 Logger에 에러 기록
```

---

## 4. 주요 데이터 구조/설정/상수 요약

### 4.1. FileLoggerIF 상수

| 상수명             | 값/설명                        |
|--------------------|-------------------------------|
| LOGIN_FAILED       | "LOGIN_FAILED"                |
| ACTION_OK          | "ACTION_OK"                   |
| logFilePath        | "D:\\\\Project\\\\SystemLogs\\\\icbs\\\\" |
| logFileName        | "serverLog"                   |
| logFileExt         | ".csv"                        |

### 4.2. ICBSStructSession 주요 필드

| 필드명            | 타입     | 설명                  |
|-------------------|----------|-----------------------|
| user_id           | String   | 사용자 ID             |
| user_name         | String   | 사용자명              |
| user_ip           | String   | 사용자 IP             |
| org               | String   | 조직                  |
| level             | String   | 등급                  |
| lastlogindate     | String   | 최종 로그인 일자       |
| strOTP            | String   | OTP                   |
| strOtpResult      | String   | OTP 인증 결과         |

---

## 5. 대표 코드 스니펫

### 5.1. ICBSRequest의 파라미터→객체 매핑

```java
public Object mapToObject(Class target) throws JServletException {
    Object obj = target.newInstance();
    Enumeration enu = getParameterNames();
    Method[] methods = target.getMethods();
    while(enu.hasMoreElements()) {
        String requestField = (String)enu.nextElement();
        String requestFieldValue = getParameter(requestField);
        // setter 탐색 및 값 할당
        // ...
    }
    return obj;
}
```

### 5.2. FileLogger의 로그 기록

```java
public static synchronized void writeLog(String strLogType, String userid, String username, String resource) {
    logFileCheck();
    bw.write(strLogType+","+getLogCurrentTime(",") + "," + userid + "," + username + "," + resource + "\\r");
    bw.flush();
}
```

### 5.3. AES256Util의 암호화/복호화

```java
public String getAESEncrypt(String str) throws ... {
    Cipher c = Cipher.getInstance(TRANSFORMATION);
    c.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(iv.getBytes()));
    byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
    BASE64Encoder encoder = new BASE64Encoder();
    String enStr = encoder.encode(encrypted);
    return enStr;
}
```

---

## 6. 데이터 구조/파라미터/설정 요약 표

### 6.1. ICBSStructSession 필드 요약

| 필드명           | 타입    | 설명           |
|------------------|---------|----------------|
| user_id          | String  | 사용자 ID      |
| user_name        | String  | 사용자명       |
| user_ip          | String  | 사용자 IP      |
| org              | String  | 조직           |
| level            | String  | 등급           |
| lastlogindate    | String  | 최종 로그인일  |
| strOTP           | String  | OTP            |
| strOtpResult     | String  | OTP 인증 결과  |

### 6.2. FileLoggerIF 로그 코드

| 코드명             | 설명           |
|--------------------|----------------|
| LOGIN_FAILED       | 로그인 실패    |
| ACTION_DENIED      | CRUD 거부      |
| SYSTEM_ERROR       | 시스템 에러    |
| ACCESS_DENIED      | 접근 실패      |
| ACTION_OK          | CRUD 성공      |
| LOGIN_SUCCESS      | 로그인 성공    |
| LOGOUT_SUCCESS     | 로그아웃 성공  |
| ACCESS_CONTENTS    | 컨텐츠 접근    |
| DML_DURATION       | DML 퍼포먼스   |

---

## 7. 결론

**공통 및 유틸리티 기능 모듈**은
- 시스템 전반의 **표준화·재사용성·일관성·보안성**을 책임지는 핵심 인프라 계층입니다.
- 날짜/문자열/암호화/인코딩/파일/세션/요청/로깅 등
  다양한 범용 기능을 제공하여,
  각 계층(Controller, Service, DAO, Presentation 등)에서
  **중복 없는 품질 높은 개발**을 가능하게 합니다.

**아키텍처적으로**
- 컨트롤러, 서비스, DAO, 프레젠테이션 등 모든 계층에서
  공통 모듈을 통해 데이터 처리, 보안, 로깅, 파일, 세션 등
  핵심 기능을 일관되게 적용할 수 있습니다.

**향후 발전 방향**
- 표준화 강화, 보안/유효성 검증 고도화,
- 프레임워크/환경설정 외부화,
- 테스트/로깅/모니터링 체계화,
- DTO/JSON 등 다양한 데이터 포맷 지원,
- 현대적 아키텍처(ORM, DI 등)와의 연계
등으로 더욱 견고하고 유연한 인프라 계층으로 발전할 수 있습니다.

---

**요약**
공통 및 유틸리티 기능 모듈은
- ICBS 시스템의 품질, 생산성, 보안, 유지보수성을
  획기적으로 향상시키는 **핵심 인프라 계층**입니다.
- 각 계층에서 반복되는 데이터 처리, 암호화, 인코딩, 파일, 세션, 요청, 로깅 등
  모든 범용 기능을 표준화·중앙화하여
  **대규모 업무 시스템의 신뢰성과 확장성**을 뒷받침합니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('8931295b-b049-4e47-9be3-024104e70d36', e'# 데이터프레임 유틸리티 함수

---

## Introduction

**데이터프레임 유틸리티 함수**는 대규모 엔터프라이즈 시스템에서 데이터 변환, 검증, 보안, 환경 관리, DB 연동 등 다양한 범용 기능을 제공하는 핵심 유틸리티 계층입니다.
이 계층은 컨트롤러, 서비스, DAO, 프레젠테이션 등 시스템 전반에서 반복적으로 사용되는 공통 로직을 중앙에서 관리하며,
코드 중복 방지, 보안 강화, 유지보수성 향상, 환경 적응성, 확장성 등을 실현합니다.

아래는 전체 시스템 내 유틸리티 계층의 의존성 및 아키텍처 흐름을 나타낸 Mermaid.js 다이어그램입니다.

**아키텍처 의존성 흐름**

```mermaid
graph TD
    subgraph "Presentation Layer"
        JSP["JspUtil"]
        ScreenMgr["ScreenManager"]
    end
    subgraph "Controller Layer"
        Controller["Controller"]
    end
    subgraph "Service Layer"
        Service["Service"]
    end
    subgraph "Business Layer"
        CodeMgr["CodeManager"]
        Util["Util"]
        SQLUtil["SQLUtil"]
    end
    subgraph "Data Access Layer"
        DBObjMgr["DBObjectManager"]
        DBObj["DBObject_ORA / DBObject_MSSQL"]
        DBConnMgr["DBConnManager"]
        JConn["JConnection"]
        JStmt["JStatement"]
        JPrepStmt["JPreparedStatement"]
        JResSet["JResultSet"]
        DBCodeConv["DBCodeConverter"]
    end
    subgraph "Configuration Layer"
        Config["Configuration"]
        JProp["JProperties"]
        Const["Const"]
    end
    subgraph "Logging Layer"
        Log["Log"]
        LogWriter["LogWriter"]
    end

    JSP --> Util
    JSP --> CodeMgr
    JSP --> ScreenMgr
    Controller --> Service
    Service --> Util
    Service --> SQLUtil
    Service --> CodeMgr
    Service --> DBObjMgr
    Service --> DBConnMgr
    DBObjMgr --> DBObj
    DBObj --> DBConnMgr
    DBConnMgr --> JConn
    JConn --> JStmt
    JConn --> JPrepStmt
    JStmt --> JResSet
    JPrepStmt --> JResSet
    JStmt --> DBCodeConv
    JPrepStmt --> DBCodeConv
    Util --> Config
    Util --> Const
    Util --> Log
    SQLUtil --> Util
    SQLUtil --> Config
    SQLUtil --> Const
    SQLUtil --> JPrepStmt
    CodeMgr --> Config
    CodeMgr --> DBConnMgr
    CodeMgr --> JStmt
    CodeMgr --> JResSet
    ScreenMgr --> Config
    Config --> JProp
    Config --> Const
    Log --> LogWriter
```

*설명:*
- **Presentation Layer**(JspUtil, ScreenManager)는 Util, CodeManager 등 유틸리티 계층을 직접 사용합니다.
- **Controller/Service/Business Layer**는 Util, SQLUtil, CodeManager, DBObjectManager 등 유틸리티 및 데이터 계층과 연결됩니다.
- **Data Access Layer**는 DBConnManager, JConnection, JStatement, JPreparedStatement, JResultSet, DBCodeConverter 등으로 구성되어 있습니다.
- **Configuration Layer**는 시스템 전체 설정을 관리하며, Const, JProperties 등과 연계됩니다.
- **Logging Layer**는 Log, LogWriter로 구성되어, 모든 계층에서 로깅을 지원합니다.

---

## 1. 데이터 변환 및 포맷팅 유틸리티

### 1.1. 주요 기능 및 구조

- **문자열 ↔ 숫자/날짜 변환**:
  - toInt, toLong, toFloat, toDouble, formatNum, formatDate, formatTime 등
- **문자셋/인코딩 변환**:
  - toHan, toUTF8, getCharacterSet, getLocaleObject 등
- **문자열 치환/분할**:
  - replaceString, split, omitComma, omitDecimals 등

#### 데이터 변환 함수 예시

```java
public static int toInt(String value) throws UtilException {
    if(value == null || value.equals("")) return 0;
    value = checkValidNumberString(value);
    try {
        return Integer.parseInt(value.trim());
    } catch(NumberFormatException ex) {
        Log.err.println(ex);
        throw new UtilException("Illegal argument \'value\': " + ex.getMessage());
    }
}
```

#### 데이터 변환 함수 요약

| 함수명          | 입력 타입 | 반환 타입 | 설명                        |
|----------------|----------|----------|----------------------------|
| toInt          | String   | int      | 문자열을 정수로 변환        |
| toLong         | String   | long     | 문자열을 long으로 변환      |
| toFloat        | String   | float    | 문자열을 float로 변환       |
| toDouble       | String   | double   | 문자열을 double로 변환      |
| formatNum      | int/long/float/double | String | 숫자 포맷팅(콤마 등)   |
| formatDate     | Date     | String   | 날짜 포맷팅                |
| formatTime     | String   | String   | 날짜 문자열 포맷팅         |
| split          | String   | String[] | 구분자로 문자열 분할       |
| replaceString  | String   | String   | 문자열 치환                |

---

## 2. 입력값 검증 및 보안 유틸리티

### 2.1. 주요 기능 및 구조

- **XSS/SQL Injection/OS Command Injection/HTTP Response Splitting 방지**
  - isNotValidXSS, isNotValidSQL, isNotOsCommandValid, isHTTP_CWE113 등
- **기본 유효성 검사**
  - CheckDecimal, CheckLength, CheckIP, checkDate 등
- **파라미터별 맞춤 검증**
  - checkParam

#### 보안 검증 함수 예시

```java
public static boolean isNotValidXSS(String paramValue) {
    if (paramValue == null || paramValue.trim().equals("")) return false;
    Matcher m = bp.matcher(paramValue);
    return m.find();
}
```

#### 보안 검증 함수 요약

| 함수명             | 설명                                  |
|-------------------|--------------------------------------|
| isNotValidXSS     | XSS 공격 문자열 포함 여부 검사         |
| isNotValidSQL     | SQL Injection 문자열 포함 여부 검사    |
| isNotOsCommandValid | OS 명령어 인젝션 문자열 검사         |
| isHTTP_CWE113     | HTTP 응답분할(CRLF) 문자열 검사       |
| checkParam        | 파라미터별 화이트리스트/정규식 검증   |

---

## 3. 환경/설정/DB 연동 유틸리티

### 3.1. 주요 기능 및 구조

- **프로퍼티 파일 로딩**
  - getPropertiesFromFile, getProp
- **DB 권한 체크**
  - checkUserGrantMenu, checkUserGrantMenuID
- **객체-맵핑/DB 문자셋 변환**
  - mapToObject, convertObjectToDBData

#### 환경설정 로딩 함수 예시

```java
public static JProperties getPropertiesFromFile(String pathName) {
    if(pathName == null || pathName.equals(""))
        throw new UtilException("Parameter \'pathName\' can not be null or \\"\\".");
    return getPropertiesFromFile(new File(pathName));
}
```

#### 환경설정/DB 연동 함수 요약

| 함수명                  | 설명                              |
|------------------------|----------------------------------|
| getPropertiesFromFile  | 환경 파일로부터 JProperties 반환  |
| getProp                | 환경 프로퍼티 값 조회             |
| checkUserGrantMenu     | 메뉴 접근 권한 체크(DB 연동)      |
| mapToObject            | 객체 매핑(필드명 기반)            |
| convertObjectToDBData  | 객체 내 문자열을 DB 문자셋으로 변환|

---

## 4. SQL 유틸리티 함수

### 4.1. 주요 기능 및 구조

- **검색 조건 파싱/인코딩/디코딩**
  - encode, decode, parse
- **동적 SQL 생성**
  - makeSearchSQL, makeSearchSQLPrepared
- **PreparedStatement 파라미터 바인딩**
  - setParameter

#### SQL 동적 생성 함수 예시

```java
public static String makeSearchSQL(String[] criteria, String tableAlias, int opOption) throws JException {
    // ... (조건 파싱 및 WHERE절 생성)
}
```

#### SQL 유틸리티 함수 요약

| 함수명                  | 설명                              |
|------------------------|----------------------------------|
| encode/decode          | 조건 문자열 인코딩/디코딩         |
| parse                  | 조건 문자열 파싱                  |
| makeSearchSQL          | 동적 WHERE절 생성                |
| makeSearchSQLPrepared  | PreparedStatement용 WHERE절 생성 |
| setParameter           | PreparedStatement 파라미터 바인딩 |

---

## 5. 프레젠테이션/화면 유틸리티 함수

### 5.1. 주요 기능 및 구조

- **URL 인코딩/디코딩**
  - urlEncode, urlDecode
- **HTML 안전 변환**
  - convertToPrintableHTML
- **콤보박스/페이징 UI 동적 생성**
  - genComboBox, getPageAnchor, getPageAnchorMHTML

#### 콤보박스 생성 함수 예시

```java
public static String genComboBox(String[] values, String[] names, String cboName, String value, String header, int size, boolean isMultiple) {
    // ... (HTML <select> 태그 생성)
}
```

#### 화면 유틸리티 함수 요약

| 함수명                  | 설명                              |
|------------------------|----------------------------------|
| urlEncode/urlDecode    | URL 인코딩/디코딩                 |
| convertToPrintableHTML | HTML 안전 문자열 변환              |
| genComboBox            | 콤보박스(HTML select) 동적 생성   |
| getPageAnchor          | 페이징 네비게이션 바 생성          |
| getPageAnchorMHTML     | 모바일용 페이징 네비게이션 생성    |

---

## 6. 예외/로깅/설정 유틸리티

### 6.1. 주요 클래스 및 역할

- **예외 계층**
  - UtilException, DBException, JException, JEJBException, JMailException, ConfigurationException 등
  - 각 계층별/도메인별 예외를 명확히 구분하여, 예외 흐름의 일관성 및 진단성 강화

- **로깅 계층**
  - Log, LogWriter
  - 로그 레벨별(디버그, 에러, 시스템 등) 로그 기록, 파일/콘솔 출력, 동기화, 일자별 파일 분리 등 지원

- **설정 계층**
  - Configuration, JProperties, Const
  - 환경설정 파일 로딩, 타입별 값 조회, 시스템 프로퍼티 관리, 상수 집합 제공

#### 예외 클래스 계층 구조

```mermaid
classDiagram
    class Exception
    class JException
    class UtilException
    class DBException
    class JEJBException
    class JMailException
    class ConfigurationException

    Exception <|-- JException
    JException <|-- UtilException
    JException <|-- DBException
    JException <|-- JEJBException
    JException <|-- JMailException
    JException <|-- ConfigurationException
```

---

## 7. 데이터/코드/화면 관리 유틸리티

### 7.1. 주요 클래스 및 역할

- **CodeManager**
  - 코드 테이블(코드값, 코드명, 다국어, 관계코드 등) 메모리 적재 및 조회, 콤보박스 UI 생성 등 지원

- **ScreenManager, Screen**
  - 화면 정의 XML 파싱, 화면별 블록/타입 관리, 동적 화면 구성 지원

- **PagedList**
  - 페이징 데이터 컨테이너, 페이지 네비게이션 UI 생성 지원

#### CodeManager 주요 메서드 요약

| 함수명                  | 설명                              |
|------------------------|----------------------------------|
| getCodeName            | 코드값으로 코드명 조회             |
| getDispName            | 코드값/언어로 표시명 조회          |
| getValues              | 메이저 코드별 코드 데이터 조회      |
| genComboBox            | 코드 기반 콤보박스 생성            |

---

## 8. 전체 유틸리티 계층 아키텍처 시퀀스 다이어그램

아래는 컨트롤러에서 데이터프레임 유틸리티 계층을 거쳐 DB 및 프레젠테이션 계층까지의 주요 호출 흐름을 시퀀스 다이어그램으로 나타낸 것입니다.

```mermaid
sequenceDiagram
    participant Controller as Controller
    participant Service as Service
    participant Util as Util
    participant SQLUtil as SQLUtil
    participant CodeMgr as CodeManager
    participant DBConnMgr as DBConnManager
    participant JConn as JConnection
    participant JStmt as JStatement
    participant JResSet as JResultSet
    participant JSPUtil as JspUtil

    Controller->>+Service: 요청 처리
    Service->>+Util: 데이터 변환/검증/보안
    Service->>+SQLUtil: SQL 동적 생성/파라미터 바인딩
    Service->>+CodeMgr: 코드명/표시명/콤보박스 조회
    Service->>+DBConnMgr: DB 커넥션 획득
    DBConnMgr->>+JConn: 커넥션 생성
    JConn->>+JStmt: Statement 생성
    JStmt->>+JResSet: 쿼리 실행/결과 반환
    Service-->>-Controller: 결과 반환
    Controller->>+JSPUtil: 페이징/콤보박스/HTML 변환
    JSPUtil-->>-Controller: UI HTML 반환
```

---

## 9. 결론 및 요약

**데이터프레임 유틸리티 함수** 계층은
- 데이터 변환, 검증, 보안, 환경설정, DB 연동, SQL 생성, 코드/화면/페이징 관리, 예외/로깅 등
시스템 전반에서 반복적으로 사용되는 공통 기능을 중앙에서 제공함으로써
**코드 중복 방지, 보안 강화, 유지보수성/확장성 향상, 환경 적응성**을 실현합니다.

- 각 함수/클래스는 실무적 요구에 충실하며,
  정적 메서드 중심, 방어적 프로그래밍, 보안 내재화, 환경 적응성 등
  실전적 설계가 돋보입니다.
- 현대적 소프트웨어 품질과 확장성을 위해
  **기능별 분리, 최신 API 활용, 정책/설정 외부화, 표준 로깅, 테스트 용이성 강화, 보안 정책의 지속적 업데이트** 등
  구조적 개선이 필요합니다.

**요약:**
- **중앙 유틸리티 계층**으로서 시스템의 일관성, 보안성, 유지보수성에 큰 기여
- **장기적으로는 모듈화, 외부화, 표준화, 테스트 강화 등으로 진화 필요**
- **실무적 요구와 현대적 품질의 균형을 추구하는 핵심 인프라 계층**입니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('0b16e18c-e5be-49d8-b54c-efd02fd06e51', e'# 웹로직 공통 기능

## 소개

웹로직 공통 기능은 전체 시스템에서 반복적으로 사용되는 핵심 로직, 데이터 접근, 서비스 처리, 그리고 컨트롤러 계층의 요청 처리를 담당합니다. 이 기능은 프레젠테이션, 비즈니스, 데이터, 도메인, 그리고 설정 레이어로 구성되어 있으며, 각 레이어는 명확한 역할 분담을 통해 시스템의 유지보수성과 확장성을 높입니다.

아래 다이어그램은 전체 시스템의 주요 의존성 흐름을 나타냅니다. 각 레이어는 독립적으로 동작하며, 상위 레이어에서 하위 레이어로의 호출 흐름을 가집니다.

설명:
- Controller Layer는 클라이언트 요청을 받아 Service Layer로 전달합니다.
- Service Layer는 비즈니스 로직을 처리하며, 필요 시 Data Access Layer를 호출합니다.
- Data Access Layer는 실제 데이터베이스와의 연동을 담당합니다.
- Domain Layer는 핵심 비즈니스 객체와 규칙을 정의합니다.
- Configuration Layer는 전체 시스템의 환경설정 및 의존성 주입을 담당합니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        A["Web Controller"]
    end
    subgraph "Business Layer"
        B["Service"]
    end
    subgraph "Data Access Layer"
        C["Repository"]
    end
    subgraph "Domain Layer"
        D["Domain Model"]
    end
    subgraph "Configuration Layer"
        E["Config"]
    end
    A --> B
    B --> C
    C --> D
    B --> D
    E --> A
    E --> B
    E --> C
```

---

## 주요 아키텍처 및 구성요소

### Controller Layer

Controller Layer는 외부 요청을 받아 적절한 Service Layer로 전달하는 역할을 합니다. 이 계층에서는 주로 HTTP 요청을 처리하며, 입력값 검증 및 응답 반환을 담당합니다.

#### 주요 역할 및 흐름

```mermaid
graph TD
    subgraph "Controller Layer"
        A["Web Controller"]
    end
    subgraph "Service Layer"
        B["Service"]
    end
    A --> B
```

설명:
Web Controller는 클라이언트로부터 요청을 받아 Service로 전달합니다.

---

### Service Layer

Service Layer는 비즈니스 로직을 담당합니다. Controller로부터 전달받은 요청을 처리하며, 필요한 경우 Data Access Layer와 상호작용합니다.

#### 주요 역할 및 흐름

```mermaid
graph TD
    subgraph "Service Layer"
        B["Service"]
    end
    subgraph "Data Access Layer"
        C["Repository"]
    end
    subgraph "Domain Layer"
        D["Domain Model"]
    end
    B --> C
    B --> D
```

설명:
Service는 Repository를 통해 데이터에 접근하거나, Domain Model을 활용하여 비즈니스 규칙을 적용합니다.

---

### Data Access Layer

Data Access Layer는 데이터베이스와의 직접적인 연동을 담당합니다. 주로 Repository 패턴을 사용하여 데이터 CRUD 작업을 수행합니다.

#### 주요 역할 및 흐름

```mermaid
graph TD
    subgraph "Data Access Layer"
        C["Repository"]
    end
    subgraph "Domain Layer"
        D["Domain Model"]
    end
    C --> D
```

설명:
Repository는 Domain Model을 활용하여 데이터베이스와의 매핑 및 데이터 조작을 수행합니다.

---

### Domain Layer

Domain Layer는 시스템의 핵심 비즈니스 객체와 규칙을 정의합니다. 이 계층은 다른 레이어에서 재사용되며, 시스템의 비즈니스 무결성을 보장합니다.

#### 주요 역할 및 흐름

```mermaid
graph TD
    subgraph "Domain Layer"
        D["Domain Model"]
    end
```

설명:
Domain Model은 비즈니스 엔티티 및 그 규칙을 정의합니다.

---

### Configuration Layer

Configuration Layer는 전체 시스템의 환경설정, 의존성 주입, 외부 리소스 연결 등을 담당합니다.

#### 주요 역할 및 흐름

```mermaid
graph TD
    subgraph "Configuration Layer"
        E["Config"]
    end
    subgraph "Presentation Layer"
        A["Web Controller"]
    end
    subgraph "Service Layer"
        B["Service"]
    end
    subgraph "Data Access Layer"
        C["Repository"]
    end
    E --> A
    E --> B
    E --> C
```

설명:
Config는 각 레이어에 필요한 설정값 및 의존성을 제공합니다.

---

## 주요 컴포넌트 요약

| 레이어              | 주요 컴포넌트      | 설명                                 |
|---------------------|--------------------|--------------------------------------|
| Controller Layer    | Web Controller     | 클라이언트 요청 처리 및 전달         |
| Service Layer       | Service            | 비즈니스 로직 처리                   |
| Data Access Layer   | Repository         | 데이터베이스 접근 및 조작            |
| Domain Layer        | Domain Model       | 비즈니스 객체 및 규칙 정의           |
| Configuration Layer | Config             | 환경설정 및 의존성 관리              |

---

## 전체 호출 시퀀스

아래 시퀀스 다이어그램은 클라이언트 요청이 각 레이어를 거쳐 처리되는 전체 흐름을 보여줍니다.

```mermaid
sequenceDiagram
    participant Client as Client
    participant Controller as Web Controller
    participant Service as Service
    participant Repository as Repository
    participant Domain as Domain Model

    Client ->> Controller: 요청 전송
    activate Controller
    Controller ->> Service: 요청 위임
    activate Service
    Service ->> Repository: 데이터 조회/저장
    activate Repository
    Repository ->> Domain: 도메인 객체 생성/조회
    activate Domain
    Domain -->> Repository: 도메인 객체 반환
    deactivate Domain
    Repository -->> Service: 데이터 반환
    deactivate Repository
    Service -->> Controller: 처리 결과 반환
    deactivate Service
    Controller -->> Client: 응답 반환
    deactivate Controller
    Note over Controller,Service: 각 단계에서 예외 처리 및 검증 수행
```

---

## 결론

웹로직 공통 기능은 명확하게 분리된 레이어 구조를 통해 시스템의 유지보수성과 확장성을 보장합니다. 각 레이어는 독립적으로 동작하며, 전체 시스템의 일관성과 안정성을 높이기 위해 상호 협력합니다. 본 문서에서는 각 레이어의 역할, 주요 컴포넌트, 그리고 전체 데이터 흐름을 시각적으로 설명하였습니다. 이를 통해 개발자는 시스템 구조를 쉽게 이해하고, 효율적으로 개발 및 유지보수를 진행할 수 있습니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('13a8f99e-47f1-4bf8-98a1-e46896a56f0a', e'# 기본 소프트웨어 패키지 목록

## 소개

본 문서는 ICBS 시스템 내 핵심 데이터 전처리 및 사용자 안내 허브 역할을 수행하는 `ICBSApplet01` 클래스의 소프트웨어 패키지 구조와 주요 구성요소, 데이터 흐름, 아키텍처 계층 및 각 기능별 상세 구현을 기술합니다.
이 클래스는 Java Applet 환경에서 **FTP 파일 다운로드, 파일 포맷 변환, CSV 저장, 결과 브라우저 연동** 등 일련의 데이터 처리 및 사용자 상호작용을 자동화합니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 주요 레이어와 데이터/제어 흐름을 시각적으로 나타냅니다.

**아키텍처 계층 및 흐름 다이어그램**

아래 다이어그램은 ICBSApplet01의 주요 역할별 계층 구조와 호출 흐름을 보여줍니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        A["ICBSApplet01 (Applet)"]
    end
    subgraph "Business Layer"
        B1["searchRecord()"]
        B2["ftpDownLoad()"]
        B3["getDiff()"]
        B4["makeSpace()"]
    end
    subgraph "Data Access Layer"
        C1["openFile()"]
        C2["readFile()"]
        C3["writeFile()"]
    end
    subgraph "Integration Layer"
        D1["FTPClient (외부)"]
        D2["File IO (Java IO)"]
        D3["브라우저 연동 (goUrl)"]
    end

    A --> B1
    B1 --> B2
    B1 --> C1
    B1 --> C2
    B1 --> C3
    B1 --> B3
    B1 --> B4
    B2 --> D1
    C1 --> D2
    C2 --> D2
    C3 --> D2
    B1 --> D3
```

> 위 다이어그램은 Applet이 사용자 입력을 받아 비즈니스 로직을 수행하고, FTP/파일 IO/브라우저 연동 등 외부 시스템과 통신하는 전체 흐름을 나타냅니다.

---

## 주요 구성요소 및 역할

### 1. Presentation Layer

#### ICBSApplet01 (Applet)

- **역할**: 사용자로부터 파라미터를 입력받고, 전체 데이터 처리 프로세스를 시작합니다.
- **주요 메서드**:
    - `init()`: 파라미터 수집 및 프로세스 시작
    - `start()`, `destroy()`, `paint(Graphics g)`: Applet 생명주기 관리

#### 코드 예시

```java
public void init() {
    fileName = getParameter("Pvalue");
    theURL = getParameter("Purl");
    strLeft = getParameter("STR_LEFT");
    strRight = getParameter("STR_RIGHT");
    searchRecord(fileName);
}
```

---

### 2. Business Layer

#### searchRecord(String strFileName)

- **역할**: 파일 존재 확인, 필요시 FTP 다운로드, 파일 오픈, 포맷 변환, CSV 저장, 브라우저 연동까지 전체 프로세스의 중심 역할
- **주요 흐름**:
    1. 로컬 파일 존재 여부 확인
    2. 없으면 FTP 다운로드 시도
    3. 파일 오픈 및 변환
    4. CSV 저장
    5. 브라우저로 결과 안내

#### ftpDownLoad(String newName)

- **역할**: FTP 서버에서 파일 다운로드
- **외부 의존**: `com.oroinc.net.ftp.FTPClient`

#### getDiff(String a, String b, int opt)

- **역할**: 두 값의 차이 계산(숫자/시각 등 다양한 포맷 지원)

#### makeSpace(int cnt)

- **역할**: 지정 길이만큼 공백 문자열 생성

#### 코드 예시

```java
public boolean ftpDownLoad(String newName) {
    com.oroinc.net.ftp.FTPClient ftp = null;
    // ... FTP 연결 및 파일 다운로드 로직 ...
}
```

---

### 3. Data Access Layer

#### openFile(String fileName)

- **역할**: 파일 오픈 및 InputStreamReader 생성

#### readFile()

- **역할**: 파일에서 데이터 읽기

#### writeFile(String str)

- **역할**: 파일에 데이터 쓰기(append)

#### 코드 예시

```java
public boolean openFile(String fileName){
    is = new InputStreamReader(new FileInputStream(down_Dir + fileName), "8859_1");
    return true;
}
```

---

### 4. Integration Layer

#### FTPClient (외부 라이브러리)

- **역할**: FTP 서버와의 통신 및 파일 다운로드

#### File IO (Java IO)

- **역할**: 파일 시스템과의 입출력

#### 브라우저 연동 (goUrl)

- **역할**: 처리 결과를 URL로 생성하여 브라우저에서 새 문서로 오픈

#### 코드 예시

```java
public void goUrl() {
    URL url = new URL(theURL + "?STR_LEFT=" + strLeft + "&STR_RIGHT=" + strRight + "&STR_FILENAME=" + fileName);
    getAppletContext().showDocument(url);
}
```

---

## 데이터 흐름 시퀀스 다이어그램

아래 시퀀스 다이어그램은 사용자가 Applet을 통해 파일 변환을 요청할 때의 전체 흐름을 보여줍니다.

```mermaid
sequenceDiagram
    participant User as 사용자
    participant Applet as ICBSApplet01
    participant FTP as FTPClient
    participant FileIO as File IO
    participant Browser as 브라우저

    User ->>+ Applet: Applet 실행/파라미터 입력
    Applet ->>+ Applet: init() 호출
    Applet ->>+ Applet: searchRecord(fileName)
    Applet ->>+ FileIO: 파일 존재 확인
    alt 파일 없음
        Applet ->>+ FTP: ftpDownLoad(fileName)
        FTP -->>- Applet: 파일 다운로드 결과
    end
    Applet ->>+ FileIO: openFile(fileName)
    Applet ->>+ FileIO: readFile()
    Applet ->>+ Applet: 데이터 변환(getDiff, makeSpace 등)
    Applet ->>+ FileIO: writeFile()
    Applet ->>+ Browser: goUrl()
    Browser -->>- User: 결과 안내
```

---

## 주요 필드 및 설정값 요약

| 필드명                | 타입              | 설명                                 | 기본값/예시                      |
|----------------------|------------------|--------------------------------------|----------------------------------|
| FTP_SERVER           | String           | FTP 서버 주소                        | "147.6.119.222"                  |
| FTP_USER             | String           | FTP 접속 계정                        | "bilcs2"                         |
| FTP_PASSWORD         | String           | FTP 접속 비밀번호                    | "ICIS21F"                        |
| FTP_DIRECTORY        | String           | 로컬 저장 디렉터리                   | "C:\\temp\\"                       |
| FTP_SERVER_DIRECTORY | String           | FTP 서버 내 파일 경로                | "/file_mt/JUNG_CDR_2/CDRVRY/"    |
| LENGTH_FILE          | int              | 파일 레코드 길이                     | 235                              |
| fileName             | String           | 처리 대상 파일명                     | 파라미터 입력값                  |
| progress             | String           | 진행상태 표시                        | "init" 등                        |

---

## 주요 메서드 요약

| 메서드명              | 주요 역할/설명                                                         | 반환값         |
|----------------------|------------------------------------------------------------------------|---------------|
| init()               | 파라미터 수집 및 searchRecord 호출                                      | void          |
| start()              | Applet 생명주기 시작 (현재 구현 없음)                                   | void          |
| destroy()            | Applet 종료 처리 (현재 구현 없음)                                       | void          |
| paint(Graphics g)    | 진행상태 등 UI 표시                                                     | void          |
| ftpDownLoad()        | FTP 파일 다운로드                                                       | boolean       |
| searchRecord()       | 파일 존재 확인, 다운로드, 변환, 저장, 브라우저 안내 전체 프로세스        | void          |
| openFile()           | 파일 오픈                                                               | boolean       |
| readFile()           | 파일 읽기                                                               | String        |
| writeFile()          | 파일 쓰기                                                               | void          |
| makeSpace()          | 공백 문자열 생성                                                        | String        |
| getDiff()            | 두 값의 차이 계산                                                       | double        |
| goUrl()              | 결과 URL 생성 및 브라우저 안내                                          | void          |
| byteToString()       | 바이트 배열 → 문자열 변환                                               | String        |
| ksc2ascii(), ascii2ksc() | 인코딩 변환 (KSC5601 <-> ASCII)                                 | String        |

---

## 데이터 모델/CSV 헤더 구조

searchRecord에서 생성하는 CSV 파일의 헤더 구조는 다음과 같습니다.

| 필드명                | 타입/길이         | 설명                  |
|----------------------|------------------|----------------------|
| dan_start_date       | STRING(8)        | 시작일자             |
| dan_start_time       | STRING(7)        | 시작시각             |
| dan_clg_no           | STRING(16)       | 발신번호             |
| dan_cld_no           | STRING(16)       | 수신번호             |
| dan_use_time         | STRING(8)        | 사용시간             |
| ...                  | ...              | ...                  |
| diff_use_time        | NUMBER(15)       | 사용시간 차이        |
| diff_start_time      | NUMBER(15)       | 시작시각 차이        |

---

## 설정값 및 보안 관련 주의사항

- FTP 서버 주소, 계정, 비밀번호 등은 코드에 하드코딩되어 있으므로, 보안상 외부 설정 파일 등으로 분리하는 것이 필요합니다.
- 파일 경로, 인코딩 등도 외부화하여 유지보수성을 높이시기 바랍니다.

---

## 결론

본 문서에서는 ICBSApplet01 클래스의 소프트웨어 패키지 구조, 계층별 역할, 데이터 흐름, 주요 메서드 및 설정값을 체계적으로 정리하였습니다.
이 클래스는 **FTP 기반 원격 파일 수집, 포맷 변환, CSV 저장, 브라우저 안내**까지의 전 과정을 자동화하며, 시스템 내 데이터 전처리 및 사용자 안내의 핵심 허브 역할을 담당합니다.
향후에는 설정 외부화, 리소스 자동 관리, 보안 강화, 현대적 UI 환경 이식 등 구조적 개선을 통해 유지보수성과 확장성을 높일 수 있습니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('1908cdbe-b8f0-4b90-a66f-a58610667b48', e'# 데이터 관리

## 소개

**데이터 관리**는 ICBS(통합 청구/정산 시스템) 및 EJBean 기반 엔터프라이즈 시스템에서
데이터베이스 엔티티, 데이터 접근 계층(DAO), 환경설정, 코드/메시지/화면 정의, 예외 및 로깅, 메시징 등
데이터의 저장, 접근, 변환, 검증, 통합, 표준화, 보안, 확장성을 총괄하는 핵심 인프라 계층입니다.

본 문서는
- 데이터베이스 엔티티 및 DAO 계층의 구조와 데이터 흐름,
- 환경설정 및 XML 관리,
- EJBean 기반 데이터 처리 아키텍처,
- 주요 데이터 모델, API, 예외/로깅 구조
를 통합적으로 설명합니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 데이터 관리 시스템의 주요 레이어 및 컴포넌트 간 의존성 흐름을 나타냅니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        UI["UI/화면/리포트"]
        API["API/외부연동"]
        JSP["JSP/Servlet"]
    end
    subgraph "Controller Layer"
        Controller["Controller/Action"]
    end
    subgraph "Business Layer"
        Service["Service/Business Logic"]
        EJBUtil["EJBUtil"]
        JSessionBean["JSessionBean"]
        JEntityBean["JEntityBean"]
    end
    subgraph "Data Access Layer"
        DAO["DAO (Data Access Object)"]
        DBConnManager["DBConnManager"]
        DBConnPool["DBConnPool"]
        JConnection["JConnection"]
        JStatement["JStatement"]
        JPreparedStatement["JPreparedStatement"]
        JResultSet["JResultSet"]
        DBObjectManager["DBObjectManager"]
        DBObject["DBObject"]
        DBCodeConverter["DBCodeConverter"]
    end
    subgraph "Messaging Layer"
        JMSMsgSender["JMSMsgSender"]
        JMSMsgReceiver["JMSMsgReceiver"]
        JMSMsgQueue["JMSMsgQueue"]
    end
    subgraph "Configuration Layer"
        Configuration["Configuration"]
        CodeManager["CodeManager"]
        MsgManager["MsgManager"]
        ScreenManager["ScreenManager"]
        Const["Const"]
    end
    subgraph "Utility Layer"
        XMLUtil["XMLUtil"]
        Util["Util"]
    end
    subgraph "Exception/Logging Layer"
        JEJBException["JEJBException"]
        DBException["DBException"]
        JException["JException"]
        Log["Log"]
        LogWriter["LogWriter"]
        StackTraceParser["StackTraceParser"]
        StackTrace["StackTrace"]
        Location["Location"]
    end
    subgraph "Data Layer"
        DB["Database (엔티티/테이블)"]
        XMLFile["XML/Properties 파일"]
    end

    UI --> Controller
    API --> Controller
    JSP --> Controller
    Controller --> Service
    Service --> DAO
    Service --> EJBUtil
    EJBUtil --> JSessionBean
    EJBUtil --> JEntityBean
    DAO --> DBConnManager
    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JStatement
    JConnection --> JPreparedStatement
    JStatement --> JResultSet
    JPreparedStatement --> JResultSet
    JConnection --> DBCodeConverter
    JStatement --> DBCodeConverter
    JPreparedStatement --> DBCodeConverter
    DBConnManager --> DBObjectManager
    DBObjectManager --> DBObject
    DBObject --> DBCodeConverter
    DAO --> DB
    DBObject --> DB
    Service --> CodeManager
    Service --> MsgManager
    Service --> ScreenManager
    CodeManager --> Configuration
    MsgManager --> Configuration
    ScreenManager --> Configuration
    CodeManager --> DB
    MsgManager --> DB
    ScreenManager --> XMLFile
    Configuration --> XMLFile
    ScreenManager --> XMLUtil
    CodeManager --> Util
    MsgManager --> Util
    Service --> Log
    Service --> JEJBException
    Service --> DBException
    XMLUtil --> Util
    Util --> Log
    Util --> JEJBException
    JMSMsgSender --> JMSMsgQueue
    JMSMsgReceiver --> JMSMsgQueue
    Log --> LogWriter
    LogWriter --> StackTraceParser
    LogWriter --> StackTrace
    StackTrace --> Location
    Configuration --> Const
```

**설명:**
- 프레젠테이션/컨트롤러/비즈니스/데이터 접근/메시징/설정/유틸리티/예외/로깅/데이터 계층이 명확히 분리되어 있으며,
  각 계층은 상호 의존성을 갖고 데이터 흐름을 관리합니다.

---

## 1. 데이터베이스 엔티티 및 DAO 계층

### 1.1. 엔티티(테이블) 구조 예시

| 컬럼명              | 타입     | 설명                |
|---------------------|----------|---------------------|
| NO                  | VARCHAR  | 회선번호            |
| SETTLE_CARRIER      | VARCHAR  | 운용사              |
| CONN_LAYER          | VARCHAR  | 연결계층            |
| ...                 | ...      | ...                 |

### 1.2. DAO 계층 구조

```mermaid
graph TD
    subgraph "Service Layer"
        Svc["Service"]
    end
    subgraph "Data Access Layer"
        DAO1["DAOBCDE240E"]
        DAO2["DAOBCDE430E"]
        DAO3["DAOBCDF3G0E"]
        DAO4["DAOBCDG730E"]
        DAO5["DAOBCDH150E"]
        DAO6["DAOBCDA150E"]
        DAO7["DAOBCDH320E"]
        DAO8["DAOBCDD170E"]
        DAO9["DAOBCDG320E"]
        DAO10["DAOBCDF320E"]
        DAO11["DAOBCDC1E0E"]
        DAO12["DAOBCDV230E"]
        DAO13["DAOBCDC560E"]
        DAO14["DAOBCDF110E"]
        DAO15["DAOBCDF610E"]
        DAO16["DAORPT_BCDF640E"]
        DAO17["DAOBCDD270E"]
        DAO18["DAOBCDC260E"]
        DAO19["DAOBCDA210E"]
        DAO20["DAOBCDA2B0E"]
        DAO21["DAOBCDC190E"]
        DAO22["DAOBCDE310E"]
        DAO23["DAOBCDE340E"]
        DAO24["DAOBCDE450E"]
        DAO25["DAOBCDF462E"]
        DAO26["DAOBCDF390E"]
        DAO27["DAOBCDZF80E"]
        DAO28["DAOBCDV310E"]
        DAO29["DAOBCDV370E"]
        DAO30["DAOBCDV410E"]
        DAO31["DAOBCDD320E"]
        DAO32["DAOBCDC110E"]
        DAO33["DAOBCDZA10E"]
    end
    subgraph "Data Layer"
        DB["DB 엔티티/테이블"]
    end
    Svc --> DAO1
    Svc --> DAO2
    Svc --> DAO3
    Svc --> DAO4
    Svc --> DAO5
    Svc --> DAO6
    Svc --> DAO7
    Svc --> DAO8
    Svc --> DAO9
    Svc --> DAO10
    Svc --> DAO11
    Svc --> DAO12
    Svc --> DAO13
    Svc --> DAO14
    Svc --> DAO15
    Svc --> DAO16
    Svc --> DAO17
    Svc --> DAO18
    Svc --> DAO19
    Svc --> DAO20
    Svc --> DAO21
    Svc --> DAO22
    Svc --> DAO23
    Svc --> DAO24
    Svc --> DAO25
    Svc --> DAO26
    Svc --> DAO27
    Svc --> DAO28
    Svc --> DAO29
    Svc --> DAO30
    Svc --> DAO31
    Svc --> DAO32
    Svc --> DAO33
    DAO1 --> DB
    DAO2 --> DB
    DAO3 --> DB
    DAO4 --> DB
    DAO5 --> DB
    DAO6 --> DB
    DAO7 --> DB
    DAO8 --> DB
    DAO9 --> DB
    DAO10 --> DB
    DAO11 --> DB
    DAO12 --> DB
    DAO13 --> DB
    DAO14 --> DB
    DAO15 --> DB
    DAO16 --> DB
    DAO17 --> DB
    DAO18 --> DB
    DAO19 --> DB
    DAO20 --> DB
    DAO21 --> DB
    DAO22 --> DB
    DAO23 --> DB
    DAO24 --> DB
    DAO25 --> DB
    DAO26 --> DB
    DAO27 --> DB
    DAO28 --> DB
    DAO29 --> DB
    DAO30 --> DB
    DAO31 --> DB
    DAO32 --> DB
    DAO33 --> DB
```

### 1.3. 데이터 흐름 예시

```mermaid
sequenceDiagram
    participant UI as 화면/프론트엔드
    participant Ctrl as Controller
    participant Svc as Service
    participant DAO as DAOBCDE240E
    participant DB as DB

    UI->>Ctrl: 조회/저장 요청
    Ctrl->>Svc: 파라미터 전달
    Svc->>DAO: searchRecord()/saveRecord() 호출
    DAO->>DB: SQL 실행
    DB-->>DAO: 결과셋 반환
    DAO-->>Svc: GauceDataSet 반환
    Svc-->>Ctrl: 비즈니스 로직 처리 결과 반환
    Ctrl-->>UI: 화면에 데이터 표시/저장 결과 알림
```

### 1.4. 트랜잭션/예외/자원 관리

```java
conn = DBConnManager.getConnection("KTIcbsDataSource");
conn.setAutoCommit(false);
try {
    // 여러 행 저장/수정
    if (trCount == trDSetCount) {
        conn.commit();
        return 1;
    } else {
        conn.rollback();
        return 0;
    }
} catch (DBException ex) {
    conn.rollback();
    throw new JEJBException("Failed to transact record: " + ex.getMessage());
} finally {
    if (pStmt != null) pStmt.close();
    DBConnManager.close(conn);
}
```

---

## 2. 환경설정 및 XML 관리

### 2.1. 환경설정(Configuration)

| 메서드명                | 설명                                         | 반환/입력 타입        |
|-------------------------|----------------------------------------------|----------------------|
| getString(name)         | 문자열 설정값 조회 (예외 발생 시 throw)       | String               |
| getInt(name, def)       | 정수 설정값 조회 (없으면 기본값 반환)         | int                  |
| getBoolean(name, def)   | 불리언 설정값 조회 (없으면 기본값 반환)       | boolean              |
| init(path)              | 설정 파일 초기화(로딩)                       | void                 |
| refresh()               | 설정 파일 경로 변경 시 재로딩                | void                 |

```java
String dbUrl = Configuration.getString("db.url");
int maxConn = Configuration.getInt("db.max_connection", 10);
boolean isDebug = Configuration.getBoolean("log.dbg", false);
```

### 2.2. 코드/메시지/화면 정의 관리

| 컴포넌트         | 주요 메서드/설명                                  |
|------------------|--------------------------------------------------|
| CodeManager      | getCodeName, getDispName, genComboBox, refresh   |
| MsgManager       | getMessage, getType, refresh                     |
| ScreenManager    | getScreen, loadFromScreenDefFile                 |

### 2.3. XML 관리 유틸리티

```mermaid
classDiagram
    class XMLUtil {
        +replaceNode(doc, old, new)
        +addChild(parent, child)
        +deleteNode(node)
        +deleteAllChildren(node)
        +save(node, filename)
        +save(node, writer, encoding)
    }
    class Node
    class Document
    XMLUtil ..> Node
    XMLUtil ..> Document
```

---

## 3. EJBean 데이터 처리 아키텍처

### 3.1. 데이터 접근 계층

```mermaid
graph TD
    subgraph "Data Access Layer"
        DBConnManager
        DBConnPool
        JConnection
        JStatement
        JPreparedStatement
        JResultSet
    end
    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JStatement
    JConnection --> JPreparedStatement
    JStatement --> JResultSet
    JPreparedStatement --> JResultSet
```

### 3.2. 예외/로깅 계층

```mermaid
graph TD
    subgraph "Exception/Logging Layer"
        JException
        JEJBException
        DBException
        Log
        LogWriter
        StackTraceParser
        StackTrace
        Location
    end
    JEJBException --> JException
    DBException --> JException
    Log --> LogWriter
    LogWriter --> StackTraceParser
    LogWriter --> StackTrace
    StackTrace --> Location
```

---

## 4. 데이터 모델 및 API 요약

### 4.1. 데이터셋 구조 예시

| 컬럼명            | 타입      | 길이/포맷 | 설명           |
|-------------------|-----------|-----------|----------------|
| NO                | STRING    | 22        | 회선번호       |
| SETTLE_CARRIER    | STRING    | 12        | 운용사         |
| ...               | ...       | ...       | ...            |

### 4.2. 주요 API/메서드

| 메서드명                         | 파라미터/타입                | 설명                                   |
|-----------------------------------|------------------------------|----------------------------------------|
| DBConnManager.getConnection()     | 없음                         | JConnection 객체 획득                  |
| JConnection.prepareStatement(sql) | String                       | JPreparedStatement 생성                |
| JPreparedStatement.executeQuery() | 없음                         | JResultSet 반환                        |
| CodeManager.getCodeName(code)     | String                       | 코드값으로 코드명 조회                 |
| MsgManager.getMessage(id)         | String                       | 메시지 ID로 메시지 내용 조회           |
| Log.info.println(msg)             | String                       | 정보 로그 기록                         |

---

## 5. 보안 및 입력값 검증

| 메서드명                  | 설명                                         |
|---------------------------|----------------------------------------------|
| isNotValidXSS(value)      | XSS 위험 문자열 검사                         |
| isNotValidSQL(value)      | SQL Injection 위험 문자열 검사               |
| isNotOsCommandValid(value)| OS 명령어 인젝션 위험 문자열 검사            |
| filter(value)             | XSS 방지용 특수문자 치환                    |

---

## 6. 결론

데이터 관리 계층은
- 데이터베이스 엔티티 및 DAO 계층을 통한 안전하고 표준화된 데이터 접근,
- 환경설정/코드/메시지/화면 정의의 중앙 집중 관리,
- EJBean 기반의 커넥션 풀, 예외/로깅, 메시징 등 엔터프라이즈 품질의 인프라,
- 보안 및 입력값 검증, XML/유틸리티 계층의 표준화
를 통해 시스템의 신뢰성, 확장성, 유지보수성을 극대화합니다.

각 계층별 컴포넌트와 데이터 흐름, 예외/로깅/보안 정책 등은
본 문서를 기반으로 추가 문서화 및 개선이 가능합니다.
데이터 관리 아키텍처의 이해와 활용은 모든 개발자의 필수 역량입니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('ff44ced8-ee96-47bb-ab8a-944766915d29', e'# 데이터베이스 엔티티 및 접근 객체 구성

---

## 소개

본 문서는 ICBS(통합 청구/정산 시스템) 내 데이터베이스 엔티티와 데이터 접근 객체(DAO, Data Access Object) 계층의 구조 및 역할을 체계적으로 정리한 것입니다.
ICBS 시스템은 통신/운송/정산/검증/통계 등 다양한 업무 도메인에 대해
- **표준화된 데이터 모델(엔티티)와**
- **DAO 계층을 통한 안전하고 일관된 데이터 접근**
을 설계 목표로 하고 있습니다.

이 문서에서는
- 각 DAO 클래스가 담당하는 엔티티(테이블)와 그 구조,
- DAO 계층의 아키텍처적 위치와 역할,
- 데이터 흐름 및 트랜잭션/예외/자원 관리,
- 확장성 및 개선점
등을 상세히 기술합니다.

---

### 전체 시스템 의존성 아키텍처 (Mermaid.js)

아래 다이어그램은 ICBS 시스템 내 주요 레이어 및 DAO 계층의 위치와 흐름을 나타냅니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        UI["UI/화면/리포트"]
        API["API/외부연동"]
    end
    subgraph "Controller Layer"
        Controller["Controller/Action"]
    end
    subgraph "Service Layer"
        Service["Service/Business Logic"]
    end
    subgraph "Data Access Layer"
        DAO["DAO (Data Access Object)"]
    end
    subgraph "Data Layer"
        DB["Database (엔티티/테이블)"]
    end

    UI --> Controller
    API --> Controller
    Controller --> Service
    Service --> DAO
    DAO --> DB
```

**설명**:
- UI/화면/리포트, API 등 프레젠테이션 계층에서 Controller를 거쳐 Service(비즈니스 로직) 계층으로 요청이 전달됩니다.
- Service 계층은 복잡한 업무 규칙을 처리하며, 데이터 접근이 필요할 때 DAO 계층을 호출합니다.
- DAO 계층은 DB 엔티티(테이블)와 직접 통신하며, 데이터 CRUD, 집계, 트랜잭션, 예외/자원 관리를 담당합니다.

---

## 1. 아키텍처 및 레이어별 역할

### 1.1. Presentation Layer (UI/화면/리포트, API)
- 사용자 인터페이스, 외부 시스템 연동 등
- 데이터 조회/입력/수정/삭제 요청을 Controller에 전달

### 1.2. Controller Layer
- 요청 라우팅, 파라미터 검증, Service 호출

### 1.3. Service Layer (Business Logic)
- 업무 규칙, 트랜잭션, 복합 로직 처리
- DAO 계층을 통해 데이터 접근

### 1.4. Data Access Layer (DAO)
- DB 엔티티(테이블)와 직접 통신
- CRUD, 집계, 트랜잭션, 예외/자원 관리
- GauceDataSet 등 표준 데이터셋 반환

### 1.5. Data Layer (엔티티/테이블)
- 실제 데이터 저장소(Oracle 등)
- 업무별 테이블(예: TB_BUPACOORIREG, TB_BUPDINVOICE 등)

---

## 2. DAO 계층의 구조 및 주요 컴포넌트

### 2.1. DAO 계층 아키텍처 (Mermaid.js)

```mermaid
graph TD
    subgraph "Presentation Layer"
        UI["UI/화면"]
        API["API"]
    end
    subgraph "Controller Layer"
        Ctrl["Controller"]
    end
    subgraph "Service Layer"
        Svc["Service"]
    end
    subgraph "Data Access Layer"
        DAO1["DAOBCDE240E"]
        DAO2["DAOBCDE430E"]
        DAO3["DAOBCDF3G0E"]
        DAO4["DAOBCDG730E"]
        DAO5["DAOBCDH150E"]
        DAO6["DAOBCDA150E"]
        DAO7["DAOBCDH320E"]
        DAO8["DAOBCDD170E"]
        DAO9["DAOBCDG320E"]
        DAO10["DAOBCDF320E"]
        DAO11["DAOBCDC1E0E"]
        DAO12["DAOBCDV230E"]
        DAO13["DAOBCDC560E"]
        DAO14["DAOBCDF110E"]
        DAO15["DAOBCDF610E"]
        DAO16["DAORPT_BCDF640E"]
        DAO17["DAOBCDD270E"]
        DAO18["DAOBCDC260E"]
        DAO19["DAOBCDA210E"]
        DAO20["DAOBCDA2B0E"]
        DAO21["DAOBCDC190E"]
        DAO22["DAOBCDE310E"]
        DAO23["DAOBCDE340E"]
        DAO24["DAOBCDE450E"]
        DAO25["DAOBCDF462E"]
        DAO26["DAOBCDF390E"]
        DAO27["DAOBCDZF80E"]
        DAO28["DAOBCDV310E"]
        DAO29["DAOBCDV370E"]
        DAO30["DAOBCDV410E"]
        DAO31["DAOBCDD320E"]
        DAO32["DAOBCDC110E"]
        DAO33["DAOBCDZA10E"]
    end
    subgraph "Data Layer"
        DB["DB 엔티티/테이블"]
    end

    UI --> Ctrl
    API --> Ctrl
    Ctrl --> Svc
    Svc --> DAO1
    Svc --> DAO2
    Svc --> DAO3
    Svc --> DAO4
    Svc --> DAO5
    Svc --> DAO6
    Svc --> DAO7
    Svc --> DAO8
    Svc --> DAO9
    Svc --> DAO10
    Svc --> DAO11
    Svc --> DAO12
    Svc --> DAO13
    Svc --> DAO14
    Svc --> DAO15
    Svc --> DAO16
    Svc --> DAO17
    Svc --> DAO18
    Svc --> DAO19
    Svc --> DAO20
    Svc --> DAO21
    Svc --> DAO22
    Svc --> DAO23
    Svc --> DAO24
    Svc --> DAO25
    Svc --> DAO26
    Svc --> DAO27
    Svc --> DAO28
    Svc --> DAO29
    Svc --> DAO30
    Svc --> DAO31
    Svc --> DAO32
    Svc --> DAO33
    DAO1 --> DB
    DAO2 --> DB
    DAO3 --> DB
    DAO4 --> DB
    DAO5 --> DB
    DAO6 --> DB
    DAO7 --> DB
    DAO8 --> DB
    DAO9 --> DB
    DAO10 --> DB
    DAO11 --> DB
    DAO12 --> DB
    DAO13 --> DB
    DAO14 --> DB
    DAO15 --> DB
    DAO16 --> DB
    DAO17 --> DB
    DAO18 --> DB
    DAO19 --> DB
    DAO20 --> DB
    DAO21 --> DB
    DAO22 --> DB
    DAO23 --> DB
    DAO24 --> DB
    DAO25 --> DB
    DAO26 --> DB
    DAO27 --> DB
    DAO28 --> DB
    DAO29 --> DB
    DAO30 --> DB
    DAO31 --> DB
    DAO32 --> DB
    DAO33 --> DB
```

**설명**:
- Service 계층은 각 업무별 DAO를 호출하여 데이터 접근을 수행합니다.
- 각 DAO는 업무별 엔티티(테이블)에 특화되어 있으며, DB와 직접 통신합니다.

---

## 3. 데이터베이스 엔티티(테이블) 구조 예시

아래는 대표적인 엔티티(테이블) 구조 예시입니다.

### 3.1. TB_BUPACOORIREG (회선/망 구성 정보)

| 컬럼명              | 타입     | 설명                |
|---------------------|----------|---------------------|
| NO                  | VARCHAR  | 회선번호            |
| SETTLE_CARRIER      | VARCHAR  | 운용사              |
| CONN_LAYER          | VARCHAR  | 연결계층            |
| TOP_OFC_NM          | VARCHAR  | 상위사무소명        |
| SWITCH_CLASS        | VARCHAR  | 스위치종류          |
| BOTTOM_OFC_NM       | VARCHAR  | 하위사무소명        |
| CONN_BUSS_SYS       | VARCHAR  | 연결업무시스템      |
| TRANS_SPEED         | VARCHAR  | 전송속도            |
| DIRECTION_NO        | VARCHAR  | 방향번호            |
| ...                 | ...      | ...                 |

### 3.2. TB_BUPDINVOICE (청구서)

| 컬럼명         | 타입     | 설명           |
|----------------|----------|----------------|
| INVOICE_NO     | VARCHAR  | 청구서번호     |
| CARRIER        | VARCHAR  | 통신사업자     |
| BILL_MONTH     | VARCHAR  | 청구년월       |
| INV_TYPE       | VARCHAR  | 청구유형       |
| BILL_AMT       | NUMBER   | 청구금액       |
| TAX            | NUMBER   | 세금           |
| INVOICE_DATE   | VARCHAR  | 청구일자       |
| DUE_DATE       | VARCHAR  | 납기일자       |
| ...            | ...      | ...            |

### 3.3. TB_BUPCCOCIRAMT (카드라인 집계)

| 컬럼명         | 타입     | 설명           |
|----------------|----------|----------------|
| BILL_MONTH     | VARCHAR  | 청구월         |
| SETTLE_CARRIER | VARCHAR  | 정산사업자     |
| NEW_CLOSE_FLAG | VARCHAR  | 신규/해지 구분 |
| CONN_CIRCUIT_NUM | NUMBER | 회선수         |
| ...            | ...      | ...            |

---

## 4. DAO 계층의 주요 컴포넌트 및 데이터 흐름

### 4.1. DAO 클래스별 역할 요약

| DAO 클래스명      | 주요 엔티티/테이블           | 주요 기능 요약                        |
|-------------------|-----------------------------|---------------------------------------|
| DAOBCDE240E       | TB_BUPACOORIREG             | 회선/망 구성 정보 조회/저장           |
| DAOBCDE430E       | TB_BUPCCOCIRAMT, TB_BUPCNETADMINAMT | 회선 연결 통계/정산 데이터 조회       |
| DAOBCDF3G0E       | TB_BCVBBLKABNR 등           | 통계성 데이터(일/월 집계) 조회        |
| DAOBCDG730E       | TB_BUPABILLBOARD 등         | 청구/정산/게시판/메일/파일 등 통합 DAO|
| DAOBCDH150E       | TB_BUPDOCRINVO_F 등         | 청구 데이터 조회/집계/저장/파일생성   |
| DAOBCDA150E       | TB_BUPACLGBAND 등           | 요금 밴드 기준 정보 관리              |
| ...               | ...                         | ...                                   |

### 4.2. 데이터 흐름 예시 (회선 정보 조회/저장)

```mermaid
sequenceDiagram
    participant UI as 화면/프론트엔드
    participant Ctrl as Controller
    participant Svc as Service
    participant DAO as DAOBCDE240E
    participant DB as DB

    UI->>Ctrl: 조회/저장 요청
    Ctrl->>Svc: 파라미터 전달
    Svc->>DAO: searchRecord()/saveRecord() 호출
    DAO->>DB: SQL 실행
    DB-->>DAO: 결과셋 반환
    DAO-->>Svc: GauceDataSet 반환
    Svc-->>Ctrl: 비즈니스 로직 처리 결과 반환
    Ctrl-->>UI: 화면에 데이터 표시/저장 결과 알림
```

---

## 5. 데이터셋 구조 및 표준화

### 5.1. GauceDataSet 구조 예시

| 컬럼명            | 타입      | 길이/포맷 | 설명           |
|-------------------|-----------|-----------|----------------|
| NO                | STRING    | 22        | 회선번호       |
| SETTLE_CARRIER    | STRING    | 12        | 운용사         |
| CONN_LAYER        | STRING    | 10        | 연결계층       |
| TOP_OFC_NM        | STRING    | 40        | 상위사무소명   |
| ...               | ...       | ...       | ...            |

### 5.2. 데이터셋 반환 예시 (코드 스니펫)

```java
GauceDataSet dSet = new GauceDataSet();
dSet.addDataColumn(new GauceDataColumn("NO", GauceDataColumn.TB_STRING, 22));
dSet.addDataColumn(new GauceDataColumn("SETTLE_CARRIER", GauceDataColumn.TB_STRING, 12));
// ... (컬럼 추가)
while (rs.next()) {
    GauceDataRow row = dSet.newDataRow();
    row.addColumnValue(rs.getString("NO"));
    row.addColumnValue(rs.getString("SETTLE_CARRIER"));
    // ... (컬럼 매핑)
    dSet.addDataRow(row);
}
```

---

## 6. 트랜잭션, 예외, 자원 관리

### 6.1. 트랜잭션 처리 예시

```java
conn = DBConnManager.getConnection("KTIcbsDataSource");
conn.setAutoCommit(false);
try {
    // 여러 행 저장/수정
    if (trCount == trDSetCount) {
        conn.commit();
        return 1;
    } else {
        conn.rollback();
        return 0;
    }
} catch (DBException ex) {
    conn.rollback();
    throw new JEJBException("Failed to transact record: " + ex.getMessage());
} finally {
    if (pStmt != null) pStmt.close();
    DBConnManager.close(conn);
}
```

### 6.2. 예외 및 자원 해제

- 모든 DBException은 JEJBException 등 커스텀 예외로 래핑하여 상위 계층에 전달
- finally 블록에서 ResultSet, Statement, Connection 등 자원 안전하게 해제

---

## 7. 표준화된 코드/명칭/콤보 데이터 제공

### 7.1. 코드 조회 DAO 예시

```java
public GauceDataSet bcda103(String ADD_ITEM) throws JEJBException {
    // ...
    String strQuery = "SELECT DISTINCT CALL_TYPE_STD AS CODE, CALL_TYPE_STD AS NAME FROM TB_BUPAFILEDEF ORDER BY CALL_TYPE_STD";
    // ...
    if(ADD_ITEM.equals("ALL")){
        row = gauceDataSet.newDataRow();
        row.addColumnValue("ALL");
        row.addColumnValue("ALL");
        gauceDataSet.addDataRow(row);
    }
    // ...
}
```

---

## 8. 개선점 및 확장성

- **SQL 파라미터화/ORM 도입**: SQL Injection 방지, 유지보수성 향상
- **DTO/VO 도입**: HashMap 기반 파라미터를 명확한 타입 객체로 개선
- **공통 유틸리티화**: DB 연결/자원 해제/예외 처리 등 반복 코드 추상화
- **로깅/모니터링 강화**: 예외 발생 시 상세 로그, 트랜잭션 로그 등 품질 관리
- **페이징/대용량 처리**: 대량 데이터 조회 시 성능 개선
- **다국어/다채널 지원**: 코드/명칭 등 다국어 처리, 다양한 데이터 포맷(JSON, XML 등) 지원

---

## 9. 결론

ICBS 시스템의 데이터베이스 엔티티 및 DAO 계층은
- **업무별 엔티티(테이블) 구조를 명확히 정의**하고,
- **DAO 계층을 통해 안전하고 표준화된 데이터 접근**을 보장합니다.

각 DAO는
- 업무 도메인별로 분리되어 있으며,
- CRUD, 집계, 트랜잭션, 예외/자원 관리 등 엔터프라이즈 품질을 충실히 반영하고 있습니다.

향후
- ORM 도입, DTO/VO 구조화, 공통 유틸리티화, 로깅/모니터링 강화 등
- 현대적 아키텍처로의 개선을 통해
더욱 견고하고 유연한 데이터 접근 계층으로 발전할 수 있습니다.

---

**요약**
- ICBS 시스템의 데이터베이스 엔티티 및 DAO 계층은
  업무별 데이터 구조와 안전한 데이터 접근을 표준화합니다.
- 각 DAO는 업무 도메인별로 분리되어,
  CRUD, 집계, 트랜잭션, 예외/자원 관리 등 엔터프라이즈 품질을 갖추고 있습니다.
- 향후 ORM, DTO, 공통화, 로깅 등 현대적 개선을 통해
  확장성과 유지보수성을 더욱 높일 수 있습니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('20739092-3d9a-4902-9dce-e2fb6727f28c', e'# 설정 및 XML 관리

## 소개

**설정 및 XML 관리**는 시스템의 환경설정, 코드/메시지/화면 정의 등 다양한 구성 요소를 외부 파일(XML, Properties 등)로부터 읽어와 중앙에서 관리하고,
애플리케이션 전체의 일관성, 확장성, 유지보수성을 보장하는 핵심 인프라 계층입니다.

본 문서에서는 다음과 같은 주요 컴포넌트의 구조와 역할, 데이터 흐름, 확장성, 그리고 XML 관리 유틸리티의 구현 방식을 체계적으로 설명합니다.

- 환경설정 관리(Configuration)
- 코드/메시지/화면 정의 관리(CodeManager, MsgManager, ScreenManager)
- XML DOM 트리 조작 및 직렬화(XMLUtil)
- 보안 및 입력값 검증(유틸리티)
- 예외 및 로깅 관리

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 의존성 및 데이터 흐름을 시각적으로 나타냅니다.

**아키텍처 다이어그램 설명:**
- 각 레이어는 역할별로 분리되어 있으며, 설정/코드/메시지/화면 정의는 중앙 설정(Configuration)에서 읽어와 관리됩니다.
- XML 관리 유틸리티(XMLUtil)는 화면 정의, 코드/메시지 관리 등에서 XML 파일을 파싱/저장하는 데 사용됩니다.
- 예외 및 로깅 계층은 모든 레이어에서 공통적으로 활용됩니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        JSP["JSP/Servlet"]
        Controller["Controller"]
    end
    subgraph "Business Layer"
        Service["Service"]
    end
    subgraph "Configuration Layer"
        Configuration["Configuration"]
        CodeManager["CodeManager"]
        MsgManager["MsgManager"]
        ScreenManager["ScreenManager"]
    end
    subgraph "Data Layer"
        DB["DB (코드/메시지/화면)"]
        XMLFile["XML/Properties 파일"]
    end
    subgraph "Utility Layer"
        XMLUtil["XMLUtil"]
        Util["Util"]
    end
    subgraph "Logging & Exception"
        Log["Log/LogWriter"]
        Exception["JException 등"]
    end

    JSP --> Controller
    Controller --> Service
    Service --> Configuration
    Service --> CodeManager
    Service --> MsgManager
    Service --> ScreenManager
    CodeManager --> Configuration
    MsgManager --> Configuration
    ScreenManager --> Configuration
    CodeManager --> DB
    MsgManager --> DB
    ScreenManager --> XMLFile
    Configuration --> XMLFile
    ScreenManager --> XMLUtil
    CodeManager --> Util
    MsgManager --> Util
    Service --> Log
    Service --> Exception
    XMLUtil --> Util
    Util --> Log
    Util --> Exception
```

**설명:**
- 프레젠테이션/비즈니스 계층은 설정/코드/메시지/화면 정의를 직접 참조하지 않고, 중앙 관리 계층을 통해 접근합니다.
- XMLUtil은 화면 정의, 코드/메시지 등 XML 기반 데이터의 파싱/저장에 활용됩니다.
- 모든 계층에서 예외 및 로깅이 일관되게 적용됩니다.

---

## 1. 환경설정 관리 (Configuration)

### 1.1. 역할 및 구조

- 시스템 전체의 환경설정(프로퍼티)을 중앙에서 관리하는 정적 유틸리티 클래스입니다.
- 설정 파일은 시스템 프로퍼티, 외부 properties 파일 등 다양한 소스에서 로딩됩니다.
- 타입별 조회(getString, getInt, getBoolean 등), 기본값 지원, 예외 처리, 동적 리프레시 기능을 제공합니다.

### 1.2. 주요 메서드 및 데이터 구조

| 메서드명                | 설명                                         | 반환/입력 타입        |
|-------------------------|----------------------------------------------|----------------------|
| getString(name)         | 문자열 설정값 조회 (예외 발생 시 throw)       | String               |
| getString(name, def)    | 문자열 설정값 조회 (없으면 기본값 반환)       | String               |
| getInt(name)            | 정수 설정값 조회                             | int                  |
| getInt(name, def)       | 정수 설정값 조회 (없으면 기본값 반환)         | int                  |
| getBoolean(name)        | 불리언 설정값 조회                           | boolean              |
| getBoolean(name, def)   | 불리언 설정값 조회 (없으면 기본값 반환)       | boolean              |
| init(path)              | 설정 파일 초기화(로딩)                       | void                 |
| refresh()               | 설정 파일 경로 변경 시 재로딩                | void                 |

#### 코드 예시

```java
// 설정값 조회 예시
String dbUrl = Configuration.getString("db.url");
int maxConn = Configuration.getInt("db.max_connection", 10);
boolean isDebug = Configuration.getBoolean("log.dbg", false);
```

---

## 2. 코드/메시지/화면 정의 관리

### 2.1. 코드 관리 (CodeManager)

- DB의 코드 테이블을 읽어와 메모리에 적재, 코드명/표시명/관계코드 등 다양한 속성을 관리합니다.
- 싱글턴 패턴으로 시스템 전체에서 단일 인스턴스만 사용합니다.
- HTML 콤보박스 동적 생성(genComboBox), 코드명/표시명 조회(getCodeName, getDispName) 등 다양한 기능을 제공합니다.

#### 주요 메서드

| 메서드명                  | 설명                                         |
|---------------------------|----------------------------------------------|
| getInstance()             | 싱글턴 인스턴스 반환                        |
| init()                    | 코드 데이터 초기화                           |
| refresh()                 | 코드 데이터 재로딩                           |
| getCodeName(code)         | 코드명 반환                                  |
| getDispName(code, lang)   | 언어별 표시명 반환                           |
| getValues(majorCd)        | 메이저 코드별 코드 집합 반환                 |
| genComboBox(...)          | 코드 기반 HTML 콤보박스 동적 생성            |

#### 데이터 구조 예시

| 필드명      | 설명           | 타입         |
|-------------|----------------|-------------|
| CD          | 코드값         | String      |
| NAME        | 코드명         | String      |
| RELCODE     | 관계코드       | String      |
| KOR/ENG     | 한글/영문명    | String      |

---

### 2.2. 메시지 관리 (MsgManager)

- DB의 메시지 테이블을 읽어와 메모리에 적재, 메시지 코드별로 한글/영문/타입 등 다양한 속성을 관리합니다.
- 싱글턴 패턴, 다국어 지원, 메시지 타입 분류, 캐싱 및 갱신(refresh) 기능을 제공합니다.

#### 주요 메서드

| 메서드명                  | 설명                                         |
|---------------------------|----------------------------------------------|
| getInstance()             | 싱글턴 인스턴스 반환                        |
| init()                    | 메시지 데이터 초기화                         |
| refresh()                 | 메시지 데이터 재로딩                         |
| getMessage(msgCode)       | 기본 언어 메시지 반환                        |
| getMessage(msgCode, lang) | 언어별 메시지 반환                           |
| getType(msgCode)          | 메시지 타입 반환                             |

---

### 2.3. 화면 정의 관리 (ScreenManager)

- 화면별 구성 정보를 XML 파일(screen.xml)로부터 읽어와, 메모리에 캐싱하여 관리합니다.
- 싱글턴 패턴, 다국어 지원, 동적 로딩 및 캐싱, 예외 처리 기능을 제공합니다.

#### 주요 메서드

| 메서드명                  | 설명                                         |
|---------------------------|----------------------------------------------|
| getInstance()             | 싱글턴 인스턴스 반환                        |
| getScreen(ctx, name)      | 화면 이름/언어별 Screen 객체 반환            |
| loadFromScreenDefFile()   | XML 파일 파싱 및 화면 정의 정보 적재         |

#### 데이터 구조 (Screen)

| 필드명      | 설명           | 타입         |
|-------------|----------------|-------------|
| name        | 화면 이름      | String      |
| blocks      | 블록 데이터    | Hashtable   |
| block_types | 블록 타입      | Hashtable   |

---

## 3. XML 관리 유틸리티 (XMLUtil)

### 3.1. 역할 및 구조

- DOM(Document Object Model) 트리의 구조적 조작(노드 추가/삭제/교체 등)과 XML 직렬화(저장)를 표준화·단순화하는 정적 유틸리티 클래스입니다.
- XML/HTML 문서의 생성, 수정, 저장 등에서 반복적으로 필요한 로직을 캡슐화하여, 코드 중복과 오류 가능성을 줄입니다.

### 3.2. 주요 메서드

| 메서드명                  | 설명                                         |
|---------------------------|----------------------------------------------|
| replaceNode(doc, old, new)| 노드 교체                                    |
| addChild(parent, child)   | 자식 노드 추가                               |
| deleteNode(node)          | 노드 삭제                                    |
| deleteAllChildren(node)   | 모든 자식 노드 삭제                          |
| save(node, filename)      | DOM 트리를 XML 파일로 저장                   |
| save(node, writer, enc)   | DOM 트리를 지정 인코딩으로 저장              |

#### 코드 예시

```java
// 모든 자식 노드 삭제
XMLUtil.deleteAllChildren(rootElement);

// DOM 트리를 파일로 저장
XMLUtil.save(document, "output.xml", "UTF-8");
```

#### Mermaid 클래스 다이어그램

```mermaid
classDiagram
    class XMLUtil {
        +replaceNode(doc, old, new)
        +addChild(parent, child)
        +deleteNode(node)
        +deleteAllChildren(node)
        +save(node, filename)
        +save(node, writer, encoding)
    }
    class Node
    class Document
    XMLUtil ..> Node
    XMLUtil ..> Document
```

---

## 4. 보안 및 입력값 검증 유틸리티

### 4.1. 주요 기능

- XSS, SQL Injection, OS Command Injection, HTTP Response Splitting 등 웹 보안 취약점 방지용 입력값 검사 및 필터링 메서드 제공
- 정규표현식 기반 검사, 화이트리스트/블랙리스트 기반 파라미터 검증, 입력값 필터링 등 다양한 보안 로직 내장

#### 대표 메서드

| 메서드명                  | 설명                                         |
|---------------------------|----------------------------------------------|
| isNotValidXSS(value)      | XSS 위험 문자열 검사                         |
| isNotValidSQL(value)      | SQL Injection 위험 문자열 검사               |
| isNotOsCommandValid(value)| OS 명령어 인젝션 위험 문자열 검사            |
| isHTTP_CWE113(value)      | HTTP 응답분할 위험 문자열 검사               |
| filter(value)             | XSS 방지용 특수문자 치환                    |
| checkParam(name, value)   | 파라미터별 맞춤 검증                        |

#### 코드 예시

```java
if (Util.isNotOsCommandValid(userInput)) {
    // 위험한 입력, 처리 중단
}
```

---

## 5. 예외 및 로깅 관리

### 5.1. 예외 계층 구조

- 설정/코드/메시지/유틸리티 등 각 계층별로 도메인 특화 예외 클래스 제공
- JException(기반), ConfigurationException, MsgException, UtilException 등
- 예외 메시지의 구조화, 다국어 지원, 원인 예외 래핑 등 확장성 고려

#### Mermaid 클래스 다이어그램

```mermaid
classDiagram
    class JException
    class ConfigurationException
    class MsgException
    class UtilException
    ConfigurationException --|> JException
    MsgException --|> JException
    UtilException --|> RuntimeException
```

### 5.2. 로깅 시스템

- Log/LogWriter 클래스에서 로그 레벨별(디버그, 정보, 에러 등) 로그 기록을 중앙에서 관리
- 환경설정 기반의 출력 정책, 파일/콘솔 출력, 일자별 파일 분리, 동기화 등 실무적 요구사항 반영

#### 코드 예시

```java
Log.info.println("설정 파일 로딩 성공");
Log.err.println("설정 파일 로딩 실패", e);
```

---

## 6. 데이터 흐름 및 연동 구조

### 6.1. 설정/코드/메시지/화면 정의의 연동

- 시스템 구동 시 JWSInit 등 초기화 클래스에서 설정 파일을 로딩하고,
  CodeManager/MsgManager/ScreenManager 등에서 DB 또는 XML 파일을 읽어 메모리에 적재
- 각 계층은 Configuration을 통해 환경설정값을 읽고,
  필요 시 XMLUtil을 통해 XML 파일을 파싱/저장

#### Mermaid 시퀀스 다이어그램

```mermaid
sequenceDiagram
    participant Startup as JWSInit
    participant Config as Configuration
    participant CodeMgr as CodeManager
    participant MsgMgr as MsgManager
    participant ScreenMgr as ScreenManager
    participant XMLUtil as XMLUtil
    participant DB as DB
    participant XMLFile as XML File

    Startup->>Config: init(confFile)
    Startup->>CodeMgr: init()
    CodeMgr->>DB: 코드 테이블 조회
    Startup->>MsgMgr: init()
    MsgMgr->>DB: 메시지 테이블 조회
    Startup->>ScreenMgr: getScreen()
    ScreenMgr->>XMLFile: screen.xml 파싱
    ScreenMgr->>XMLUtil: XML 파싱/저장
```

---

## 7. 주요 설정/코드/메시지/화면 정의 파일 구조

### 7.1. 설정 파일 예시 (pdf.properties)

| 키                  | 타입    | 기본값/예시           | 설명                       |
|---------------------|---------|-----------------------|----------------------------|
| db.url              | String  | jdbc:oracle:thin:...  | DB 접속 URL                |
| db.max_connection   | int     | 10                    | 최대 커넥션 수             |
| log.dbg             | boolean | true                  | 디버그 로그 출력 여부      |
| msg.lang            | String  | KO                    | 기본 메시지 언어           |
| screen.rows_per_page| int     | 20                    | 페이지당 행 수             |

### 7.2. 코드/메시지 테이블 구조

| 필드명      | 타입     | 설명           |
|-------------|----------|----------------|
| majorcd     | String   | 메이저 코드    |
| minorcd     | String   | 마이너 코드    |
| cdname      | String   | 코드명         |
| kordisp     | String   | 한글 표시명    |
| engdisp     | String   | 영문 표시명    |
| relcode     | String   | 관계 코드      |
| useyn       | String   | 사용 여부(Y/N) |

### 7.3. 화면 정의 XML 예시

```xml
<screens>
    <screen name="MAIN">
        <header type="file">header.jsp</header>
        <body type="file">mainBody.jsp</body>
        <footer type="file">footer.jsp</footer>
    </screen>
    ...
</screens>
```

---

## 8. 결론

**설정 및 XML 관리** 계층은 시스템 전체의 환경설정, 코드/메시지/화면 정의 등
핵심 구성 정보를 외부 파일로부터 안전하게 읽어와 중앙에서 관리함으로써,
애플리케이션의 일관성, 확장성, 유지보수성을 크게 향상시킵니다.

- **Configuration/CodeManager/MsgManager/ScreenManager** 등은
  각 도메인별로 데이터의 중앙 집중 관리와 타입 안전성, 예외 처리, 캐싱/갱신 등 실무적 요구를 충실히 반영합니다.
- **XMLUtil** 등 유틸리티 계층은
  XML/HTML 문서의 구조적 조작과 직렬화, 보안 검증 등 반복적이고 오류가 발생하기 쉬운 작업을 표준화합니다.
- **예외 및 로깅 시스템**은
  모든 계층에서 일관된 예외 처리와 운영/장애 진단을 지원합니다.

향후에는
- 제네릭/최신 컬렉션, 표준 로깅 프레임워크, 고급 XML 기능, 보안 정책 외부화 등
  현대적 소프트웨어 품질 기준에 맞춘 구조적 개선이 필요합니다.

**설정 및 XML 관리 계층은 시스템의 신뢰성과 확장성, 유지보수성의 기반이 되는
핵심 인프라로, 모든 개발자가 반드시 이해하고 활용해야 할 영역입니다.**', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('1f636485-e662-4d04-bad2-36b0fb67b0cf', e'# EJBean 데이터 처리

## 소개

EJBean 데이터 처리 시스템은 엔터프라이즈 Java 환경에서 데이터베이스, 메시지, 화면, 코드, 예외, 로깅 등 다양한 엔터프라이즈 기능을 표준화하고, 확장성·안정성·유지보수성을 극대화하기 위해 설계된 통합 데이터 처리 프레임워크입니다.
본 문서는 주요 컴포넌트(데이터베이스 접근, 커넥션 풀, 코드/메시지 관리, 예외/로깅, 화면 관리 등)의 구조와 데이터 흐름, 아키텍처적 역할, 각 계층의 책임 및 상호작용을 체계적으로 설명합니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 주요 레이어와 컴포넌트 간 의존성 및 호출 흐름을 시각적으로 나타냅니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        SM["ScreenManager"]
        CM["CodeManager"]
        MSGM["MsgManager"]
    end
    subgraph "Business Layer"
        EJBUtil["EJBUtil"]
        JSessionBean["JSessionBean"]
        JEntityBean["JEntityBean"]
    end
    subgraph "Data Access Layer"
        DBConnManager["DBConnManager"]
        DBConnPool["DBConnPool\\n(DBConnPool_WL, DBConnPool_9I, DBConnPool_AP)"]
        JConnection["JConnection"]
        JStatement["JStatement"]
        JPreparedStatement["JPreparedStatement"]
        JResultSet["JResultSet"]
        DBObjectManager["DBObjectManager"]
        DBObject["DBObject\\n(DBObject_ORA, DBObject_MSSQL)"]
        DBCodeConverter["DBCodeConverter"]
    end
    subgraph "Messaging Layer"
        JMSMsgSender["JMSMsgSender"]
        JMSMsgReceiver["JMSMsgReceiver"]
        JMSMsgQueue["JMSMsgQueue"]
    end
    subgraph "Exception/Logging Layer"
        JEJBException["JEJBException"]
        DBException["DBException"]
        JException["JException"]
        Log["Log"]
        LogWriter["LogWriter"]
        StackTraceParser["StackTraceParser"]
        StackTrace["StackTrace"]
        Location["Location"]
    end
    subgraph "Configuration Layer"
        Configuration["Configuration"]
        Const["Const"]
    end

    %% 호출 흐름
    SM --> CM
    SM --> MSGM
    SM --> Configuration
    CM --> Configuration
    MSGM --> Configuration

    EJBUtil --> JSessionBean
    EJBUtil --> JEntityBean
    EJBUtil --> JEJBException
    EJBUtil --> Configuration

    JSessionBean --> JEJBException
    JEntityBean --> JEJBException

    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JStatement
    JConnection --> JPreparedStatement
    JStatement --> JResultSet
    JPreparedStatement --> JResultSet
    JConnection --> DBCodeConverter
    JStatement --> DBCodeConverter
    JPreparedStatement --> DBCodeConverter
    DBConnManager --> DBObjectManager
    DBObjectManager --> DBObject
    DBObject --> DBCodeConverter
    DBObject --> Configuration

    JMSMsgSender --> JMSMsgQueue
    JMSMsgReceiver --> JMSMsgQueue

    JStatement --> DBException
    JPreparedStatement --> DBException
    JConnection --> DBException
    DBConnManager --> DBException
    DBObject --> DBException
    JEJBException --> JException
    DBException --> JException

    Log --> LogWriter
    LogWriter --> StackTraceParser
    LogWriter --> StackTrace
    StackTrace --> Location

    Configuration --> Const
```
*위 다이어그램은 각 레이어별 주요 컴포넌트와 호출/의존 흐름을 나타냅니다.*

---

# 주요 컴포넌트 및 데이터 흐름

## 1. 데이터베이스 접근 계층

### 1.1. 커넥션 풀 및 커넥션 관리

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Data Access Layer"
        DBConnManager
        DBConnPool
        JConnection
        JStatement
        JPreparedStatement
        JResultSet
    end
    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JStatement
    JConnection --> JPreparedStatement
    JStatement --> JResultSet
    JPreparedStatement --> JResultSet
```
*DBConnManager를 통해 커넥션 풀에서 JConnection을 획득, Statement/PreparedStatement/ResultSet을 생성 및 관리합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| DBConnManager    | DBConnPool 구현체를 동적으로 로딩, 커넥션 획득/반납의 단일 진입점                        |
| DBConnPool       | 커넥션 풀 인터페이스, 다양한 구현체(DBConnPool_WL, DBConnPool_9I, DBConnPool_AP 등) 지원 |
| JConnection      | JDBC Connection 래퍼, 트랜잭션/속성/Statement 생성 등 DB 연결 관리                        |
| JStatement       | JDBC Statement 래퍼, SQL 실행/로깅/예외 처리/성능 측정 등 부가 기능 제공                  |
| JPreparedStatement| PreparedStatement 래퍼, 파라미터 관리/로깅/예외 처리/성능 측정 등 부가 기능 제공         |
| JResultSet       | ResultSet 래퍼, 데이터 추출/변환/예외 처리/코드 변환 등 부가 기능 제공                   |

#### 예시 코드

```java
JConnection conn = DBConnManager.getConnection();
JPreparedStatement pstmt = conn.prepareStatement("SELECT * FROM USER WHERE ID = ?");
pstmt.setInt(1, 1001);
JResultSet rs = pstmt.executeQuery();
while(rs.next()) {
    String name = rs.getString("NAME");
    // ...
}
DBConnManager.close(conn);
```

---

### 1.2. DB 객체 및 ID 생성 전략

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Data Access Layer"
        DBObjectManager
        DBObject
        MaxIDGen
        SeqIDGen
        SPIDGen
    end
    DBObjectManager --> DBObject
    DBObject --> MaxIDGen
    DBObject --> SeqIDGen
    DBObject --> SPIDGen
```
*DBObjectManager가 DBMS별 DBObject 구현체와 다양한 IDGen 전략을 관리합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| DBObjectManager  | DBMS별 DBObject 구현체 및 IDGen 전략의 중앙 관리/주입                                     |
| DBObject         | DB 객체 추상 클래스, IDGen 인터페이스 구현, 컬럼 주석 조회 등 표준화                      |
| MaxIDGen/SeqIDGen/SPIDGen | 다양한 ID 생성 정책(최대값, 시퀀스, 저장 프로시저 등) 구현체                    |

#### 예시 코드

```java
DBObject dbo = DBObjectManager.getDBObject();
String nextId = dbo.getNextID("USER", "ID", null);
```

---

### 1.3. DB 코드 변환 및 환경설정

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Data Access Layer"
        DBCodeConverter
    end
    DBCodeConverter --> Configuration
```
*DBCodeConverter는 환경설정에 따라 문자셋 변환을 수행합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| DBCodeConverter  | DB ↔ 애플리케이션 간 문자셋 변환(인코딩) 유틸리티                                        |
| Configuration    | 환경설정 파일 관리, 설정값 조회/타입 변환/예외 처리 등                                    |

---

## 2. 메시지/코드/화면 관리 계층

### 2.1. 코드/메시지/화면 관리

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Presentation Layer"
        CodeManager
        MsgManager
        ScreenManager
    end
    CodeManager --> Configuration
    MsgManager --> Configuration
    ScreenManager --> CodeManager
    ScreenManager --> MsgManager
```
*CodeManager/MsgManager/ScreenManager는 환경설정에 따라 코드/메시지/화면 정의를 관리합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| CodeManager      | 코드 테이블 관리, 코드명/표시명/관계코드/콤보박스 생성 등 지원                            |
| MsgManager       | 메시지 관리, 메시지 타입/내용 조회, 다국어 지원                                            |
| ScreenManager    | 화면 정의(XML) 관리, 화면 블록/타입/구성 정보 제공                                       |

---

## 3. 예외/로깅 계층

### 3.1. 예외 처리

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Exception/Logging Layer"
        JException
        JEJBException
        DBException
        JMailException
        JPropertiesException
        ConfigurationException
    end
    JEJBException --> JException
    DBException --> JException
    JMailException --> JException
    JPropertiesException --> JException
    ConfigurationException --> JException
```
*모든 도메인별 예외는 JException을 상속하여 일관된 예외 처리 체계를 구성합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| JException       | 커스텀 예외의 최상위 클래스, 코드/메시지/원인 예외 등 다양한 정보 래핑                    |
| JEJBException    | EJB 환경 특화 예외, 시스템 예외 래핑 및 추가 정보 제공                                    |
| DBException      | DB 작업 특화 예외, SQLException 등 래핑                                                  |
| JMailException   | 메일 처리 특화 예외                                                                      |
| JPropertiesException | 설정 파일 처리 특화 예외                                                             |
| ConfigurationException | 환경설정 처리 특화 예외                                                            |

---

### 3.2. 로깅 및 스택 트레이스

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Exception/Logging Layer"
        Log
        LogWriter
        StackTraceParser
        StackTrace
        Location
    end
    Log --> LogWriter
    LogWriter --> StackTraceParser
    LogWriter --> StackTrace
    StackTrace --> Location
```
*Log/LogWriter는 로그 레벨별 로그 기록, StackTrace/Location은 코드 위치 정보 추출 및 포맷을 담당합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| Log              | 로그 레벨별(LogWriter) 인스턴스 제공, 중앙 로그 진입점                                    |
| LogWriter        | 로그 레벨/포맷/파일/콘솔 출력/동기화 등 로깅 정책 관리                                    |
| StackTraceParser | 예외 스택 트레이스 파싱, 호출자/오너 클래스명 추출                                       |
| StackTrace       | 실행 시점의 스택 트레이스 캡처 및 Location 객체화                                         |
| Location         | 스택 프레임 한 줄을 구조화(패키지/클래스/메서드/파일/라인)                                |

---

## 4. 메시징 계층

### 4.1. JMS 메시지 송수신

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Messaging Layer"
        JMSMsgSender
        JMSMsgReceiver
        JMSMsgQueue
    end
    JMSMsgSender --> JMSMsgQueue
    JMSMsgReceiver --> JMSMsgQueue
```
*JMSMsgSender/Receiver는 JMSMsgQueue를 통해 메시지 송수신을 수행합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| JMSMsgSender     | JMS 메시지 생성(ObjectMessage 등), 큐 송신, 종료 신호 전송 등 송신 표준화                 |
| JMSMsgReceiver   | JMS 큐로부터 메시지 동기 수신, 예외 처리/로깅/자원 관리                                   |
| JMSMsgQueue      | JMS 큐/커넥션 팩토리 관리, 송수신자에 큐 객체 제공                                       |

---

## 5. 환경설정 계층

### 5.1. 환경설정 및 상수 관리

#### 아키텍처 다이어그램

```mermaid
graph TD
    subgraph "Configuration Layer"
        Configuration
        Const
    end
    Configuration --> Const
```
*Configuration은 환경설정 파일을 관리하며, Const는 전역 상수를 제공합니다.*

#### 주요 클래스 및 역할

| 컴포넌트         | 설명                                                                                      |
|------------------|------------------------------------------------------------------------------------------|
| Configuration    | 환경설정 파일 로딩, 설정값 조회/타입 변환/예외 처리 등                                    |
| Const            | 시스템 전역 상수(환경설정 키, 코드값, DBMS/서버/인코딩/언어 등) 집합                      |

---

# 데이터 모델 및 API 요약

## 1. 주요 데이터 모델 (예시)

| 필드명      | 타입      | 설명                         |
|-------------|-----------|------------------------------|
| Msg.type    | String    | 메시지 유형 (ERR/INFO 등)    |
| Msg.message | String    | 메시지 내용                  |
| Screen.name | String    | 화면 이름                    |
| Screen.blocks | Map     | 블록명 → 블록 내용           |
| Screen.block_types | Map| 블록명 → 블록 타입           |
| PagedList.totalCnt | int| 전체 데이터 건수             |
| PagedList.pList | List | 현재 페이지 데이터 리스트     |

---

## 2. 주요 API/메서드 (예시)

| 메서드명                         | 파라미터/타입                | 설명                                   |
|-----------------------------------|------------------------------|----------------------------------------|
| DBConnManager.getConnection()     | 없음                         | JConnection 객체 획득                  |
| JConnection.prepareStatement(sql) | String                       | JPreparedStatement 생성                |
| JPreparedStatement.executeQuery() | 없음                         | JResultSet 반환                        |
| CodeManager.getCodeName(code)     | String                       | 코드값으로 코드명 조회                 |
| MsgManager.getMessage(id)         | String                       | 메시지 ID로 메시지 내용 조회           |
| JMSMsgSender.sendMessage(msg)     | Object                       | JMS 메시지 송신                        |
| JMSMsgReceiver.receiveMessage()   | 없음                         | JMS 메시지 수신                        |
| Log.info.println(msg)             | String                       | 정보 로그 기록                         |

---

## 3. 예외/로깅/메시지 구조

| 예외 클래스         | 주요 필드/메서드            | 설명                                 |
|---------------------|----------------------------|--------------------------------------|
| JException          | code, detail, msg          | 예외 코드, 원인 예외, 메시지 객체    |
| JEJBException       | sqlDetail, dbDetail, msg   | SQL/DB 예외, 메시지 객체            |
| DBException         | sqlDetail, msg             | SQL 예외, 메시지 객체               |
| LogWriter.println() | 다양한 오버로딩            | 로그 메시지/예외/스택트레이스 기록  |

---

# 결론

EJBean 데이터 처리 시스템은 엔터프라이즈 Java 환경에서 데이터베이스, 메시지, 코드, 화면, 예외, 로깅, 환경설정 등 다양한 인프라 기능을 표준화하고,
각 계층별 책임 분리와 확장성, 일관성, 안정성을 극대화하는 구조로 설계되었습니다.
각 컴포넌트는 명확한 역할과 인터페이스를 갖추고 있으며,
Mermaid.js 다이어그램을 통해 전체 아키텍처와 데이터 흐름을 직관적으로 파악할 수 있습니다.

이 문서는 시스템의 구조적 이해, 유지보수, 확장, 신규 개발 시 필수적인 참조 자료로 활용될 수 있습니다.
각 계층별 세부 구현 및 API, 데이터 모델, 예외/로깅 정책 등은 본 문서를 기반으로 추가 문서화가 가능합니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('4c14f6fe-a8e4-4dd1-af81-beefd4bc15d4', e'# 업무 및 금융 모듈

## 소개

**업무 및 금융 모듈**은 대규모 엔터프라이즈 시스템에서 운송사 청구/지불 집계, 금융 정산, 통계, 리포트, 파일 입출력, DB 접근, 보안 등 다양한 업무를 표준화된 구조로 처리하기 위한 핵심 백엔드 아키텍처입니다.
이 모듈은 EJB(Session Bean) 기반의 비즈니스 로직 계층, Delegate/Facade 서비스 계층, DAO/DB 유틸리티, 파일 입출력, 보안·입력값 검증, 프레젠테이션 계층 지원 유틸리티 등으로 구성되어 있습니다.
각 계층은 관심사의 분리, 표준화, 확장성, 보안성, 유지보수성을 극대화하도록 설계되어 있습니다.

아래는 전체 시스템의 주요 의존성 및 아키텍처 흐름을 나타낸 Mermaid.js 다이어그램입니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        UI["웹 UI/리포트"]
        Controller["Web Controller"]
        Batch["Batch Scheduler"]
        API["API Gateway"]
        JSP["JSP/Servlet"]
        JRequest["JRequest"]
        JSession["JSession"]
        JFileUpload["JFileUpload"]
        JFileDownload["JFileDownload"]
    end

    subgraph "Controller Layer"
        EJBHome["EJB Home (SBCDA110EHome, SRPT_BCDF440EHome 등)"]
    end

    subgraph "Service Layer"
        Delegate["Delegate/Facade (FCBCDD160E 등)"]
        Remote["EJB Remote (SBCDA110E, SRPT_BCDF440E 등)"]
        Bean["Session Bean (SBCDA110EBean, SRPT_BCDF440EBean 등)"]
    end

    subgraph "Business/Domain Layer"
        DBObjectManager["DBObjectManager"]
        DBObject["DBObject"]
        FileInfo["FileInfo"]
        StructFile["StructFile"]
        JUploadedFile["JUploadedFile"]
    end

    subgraph "Data Access Layer"
        DAO["DAO (DAORPT_BCDF440E 등)"]
        MaxIDGen["MaxIDGen"]
        SeqIDGen["SeqIDGen"]
        SPIDGen["SPIDGen"]
        IDGen["IDGen"]
        DBConnManager["DBConnManager"]
        DBConnPool["DBConnPool"]
        JConnection["JConnection"]
        JPreparedStatement["JPreparedStatement"]
        JResultSet["JResultSet"]
        JStatement["JStatement"]
        DB["DB/외부시스템"]
    end

    subgraph "Utility/Configuration"
        Util["Util"]
        SQLUtil["SQLUtil"]
        JspUtil["JspUtil"]
        DBCodeConverter["DBCodeConverter"]
        StackTraceParser["StackTraceParser"]
        Configuration["Configuration"]
        Gauce["GauceDataSet"]
    end

    UI --> Controller
    Controller --> EJBHome
    Controller --> Delegate
    Delegate --> Remote
    EJBHome --> Remote
    Remote --> Bean
    Bean --> DBObjectManager
    Bean --> DAO
    Bean --> FileInfo
    Bean --> Gauce
    DAO --> DB
    DAO --> Gauce
    DBObjectManager --> DBObject
    DBObject --> IDGen
    DBObject --> FileInfo
    JFileUpload --> FileInfo
    JFileUpload --> StructFile
    JFileUpload --> JUploadedFile
    JFileDownload --> FileInfo

    Bean --> DBConnManager
    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JPreparedStatement
    JConnection --> JStatement
    JPreparedStatement --> JResultSet

    IDGen --> MaxIDGen
    IDGen --> SeqIDGen
    IDGen --> SPIDGen

    Util --> SQLUtil
    Util --> JspUtil
    Util --> DBCodeConverter
    Util --> StackTraceParser
    Util --> Configuration
```

**설명:**
- 프레젠테이션 계층에서 요청이 들어오면, Controller, JSP/Servlet, JRequest, JSession, JFileUpload, JFileDownload 등 유틸리티를 통해 입력값 처리, 세션 관리, 파일 입출력 등을 수행합니다.
- Controller Layer(EJB Home, Delegate/Facade)는 비즈니스 로직 세션빈(Session Bean) 또는 Delegate를 호출합니다.
- Service Layer에서는 실제 비즈니스 로직(Session Bean)과 Delegate/Facade가 존재하며, DAO, 도메인 객체, 유틸리티와 협력합니다.
- Data Access Layer는 IDGen, DBConnManager, DAO, JConnection 등으로 DB 작업을 처리합니다.
- Utility/Configuration 계층은 입력값 검증, SQL 생성, 문자셋 변환, 환경설정, 데이터셋 표준화(GauceDataSet) 등 공통 기능을 제공합니다.

---

## 1. 비즈니스 로직 및 서비스 계층

### 1.1. Session Bean 기반 업무 모듈

#### 주요 클래스 및 역할

| 클래스명            | 역할 및 설명                                               |
|---------------------|-----------------------------------------------------------|
| SBCDA110EBean       | 운송사 청구/지불 집계 데이터의 조회 및 저장 비즈니스 로직  |
| SBCDA110E           | EJB 원격 인터페이스 (클라이언트 호출용)                   |
| SBCDA110EHome       | EJB 홈 인터페이스 (생성/생명주기 관리)                    |
| SRPT_BCDF440EBean   | 통계/리포트 데이터 집계 비즈니스 로직                      |
| SRPT_BCDF440E       | 통계/리포트 서비스 원격 인터페이스                        |
| SRPT_BCDF440EHome   | 통계/리포트 EJB 홈 인터페이스                             |

#### 대표 메서드 및 시그니처

| 메서드명            | 설명                                 | 입출력/예외         |
|---------------------|--------------------------------------|---------------------|
| searchRecord1       | 운송사/연도별 집계 조회              | GauceDataSet, JEJBException |
| searchRecord2       | 운송사/월별 집계 조회                | GauceDataSet, JEJBException |
| saveRecord          | 집계 데이터 등록/수정(트랜잭션 처리)  | int, JEJBException  |
| searchgraphRecord   | 통계 데이터 집계 조회                | GauceDataSet, JEJBException |
| printRecord         | 리포트용 데이터셋 생성(Stub)          | GauceDataSet, JEJBException |

#### 코드 예시

```java
public GauceDataSet searchRecord1(String callTypeStd) throws JEJBException {
    return daoBCDA110E.searchRecord1(callTypeStd);
}
```

---

### 1.2. Delegate/Facade 기반 금융 기능 모듈

#### 구조 및 패턴

- 각 Delegate 클래스(FCBCDD160E 등)는 EJB Session Bean을 lookup하여 실제 비즈니스 로직을 위임 호출합니다.
- 예외 발생 시 RemoteException을 표준 예외(JException)로 변환하여 상위 계층에 전달합니다.
- 모든 데이터 반환은 GauceDataSet 등 표준 데이터셋 포맷으로 통일합니다.

#### 대표 Delegate 클래스 구조

```java
public class FCBCDD160E
{
    SBCDD160E remoteSBCDD160EBean = null;

    public FCBCDD160E()
    {
        try {
            remoteSBCDD160EBean = (SBCDD160E) EJBUtil.getRemote("com_kt_icbs_SBCDD160EBean");
        } catch (Exception ex) {
            Log.err.println(ex, "fc - FCBCDD160E: constructor");
        }
    }

    public GauceDataSet searchRecord(String strSettleCarrier, String strBillMonth, ...) throws JException
    {
        try {
            return remoteSBCDD160EBean.searchRecord(strSettleCarrier, strBillMonth, ...);
        } catch (RemoteException ex) {
            Log.err.println(ex, "fc - FCBCDD160E: searchRecord()");
            throw new JException(ex, new Msg("MBCDZ001"));
        }
    }
}
```

#### 주요 Delegate 메서드 요약

| 메서드명           | 역할                        | 입력 파라미터                  | 반환값         |
|-------------------|----------------------------|-------------------------------|---------------|
| searchRecord      | 정산/청구 데이터 조회       | 정산사업자, 청구월, 기간 등    | GauceDataSet  |
| getSettleCarrier  | 정산사업자 목록 조회        | 없음                          | GauceDataSet  |
| getBillMonth      | 청구년월 목록 조회          | 정산사업자                    | GauceDataSet  |
| getReportMaster   | 마스터 데이터 조회          | 정산사업자, 청구월, 기간 등    | GauceDataSet  |
| getReportDetail   | 상세 데이터 조회            | 정산사업자, 청구월, 항목 등    | GauceDataSet  |

---

### 1.3. SRPT 보고서 세션빈 모듈

#### 주요 클래스 및 역할

| 클래스명                | 역할 요약                                                                                   |
|------------------------|---------------------------------------------------------------------------------------------|
| SRPT_BCDF440EHome      | EJB 세션빈의 생성 및 생명주기 관리                                                          |
| SRPT_BCDF440E          | 비즈니스 서비스(통계 조회 등) 원격 호출 인터페이스                                          |
| SRPT_BCDF440EBean      | 실제 비즈니스 로직 구현체. DAO 호출, 데이터셋 가공, 트랜잭션/예외 관리 등                    |
| DAORPT_BCDF440E        | 실제 DB 쿼리 실행, 집계, GauceDataSet 변환 등 데이터 접근/가공 책임                         |

#### 대표 메서드 및 파라미터

| 메서드명                | 파라미터 (타입)         | 반환값         | 설명                                 |
|------------------------|------------------------|---------------|--------------------------------------|
| searchgraphRecord      | HashMap hmParam        | GauceDataSet  | 통계 데이터 집계 조회                |
| printRecord            | HashMap hmParam        | GauceDataSet  | 리포트용 데이터셋(Stub, 확장 가능)   |

---

## 2. 데이터 접근 및 유틸리티 계층

### 2.1. IDGen 및 DB 커넥션 관리

| 클래스명      | 설명                                         |
|---------------|----------------------------------------------|
| IDGen         | ID 생성 정책 인터페이스 (MAX, SEQ, SP 지원)  |
| MaxIDGen      | 테이블 최대값+1 방식 ID 생성                  |
| SeqIDGen      | 오라클 시퀀스 기반 ID 생성                   |
| SPIDGen       | 저장 프로시저 기반 ID 생성                   |
| DBConnManager | DB 커넥션 풀 관리의 중앙 진입점              |
| DBConnPool    | 커넥션 풀 인터페이스                         |
| JConnection   | JDBC Connection 래퍼                         |

#### IDGen 인터페이스 예시

```java
public String getNextID(String name, String targetName, String whereCondition) throws DBException {
    // 예: SELECT my_seq.nextval FROM dual
}
```

#### DBConnManager 예시

```java
public static JConnection getConnection() throws DBException {
    if(dbcp == null)
        throw new DBException("DBConnPool object is null. Check error log.");
    return dbcp.getConnection();
}
```

---

### 2.2. DB 유틸리티

| 클래스명            | 설명                                         |
|---------------------|----------------------------------------------|
| JPreparedStatement  | JDBC PreparedStatement 래퍼                  |
| JResultSet          | JDBC ResultSet 래퍼                          |
| JStatement          | JDBC Statement 래퍼                          |

#### JPreparedStatement 예시

```java
public void setString(int parameterIndex, String x) throws DBException {
    stmt.setString(parameterIndex, converter.convertDataToDBData(x));
    params.put(new Integer(parameterIndex), "\'" + x + "\'");
}
```

---

### 2.3. 파일 입출력

| 클래스명         | 설명                                           |
|------------------|------------------------------------------------|
| JFileUpload      | 파일 업로드 처리, 파일 저장/파싱                |
| JFileDownload    | 파일 다운로드 Servlet                           |
| FileInfo         | 파일 메타데이터 DTO                             |
| StructFile       | 업로드 파일 구조 정보 DTO                       |
| JUploadedFile    | 업로드 파일 단위 정보 VO                        |

#### FileInfo 필드 요약

| 필드명            | 타입     | 설명                    |
|-------------------|----------|-------------------------|
| fileId            | String   | 파일 식별자             |
| uniqueFileName    | String   | 고유 파일명(중복 방지)  |
| fileCategory      | String   | 파일 분류               |
| relativePath      | String   | 상대 경로               |
| fileName          | String   | 원본 파일명             |
| fileExt           | String   | 파일 확장자             |
| fileSize          | String   | 파일 크기               |
| useyn             | String   | 사용 여부               |
| regdt/upddt       | Date     | 등록/수정일             |
| absolutePath      | String   | 전체 경로               |

---

### 2.4. 유틸리티/보안/입력값 검증

| 클래스명           | 설명                                           |
|--------------------|------------------------------------------------|
| Util               | 범용 데이터 변환, 입력값 검증, 보안 등          |
| SQLUtil            | 검색 조건 파싱, 동적 SQL 생성                   |
| JspUtil            | JSP/Servlet 지원, 콤보박스/페이징 등            |
| DBCodeConverter    | 문자셋 변환                                     |
| StackTraceParser   | 예외 스택 트레이스 파싱                         |

#### Util 주요 보안 메서드

| 메서드명             | 설명                                         |
|----------------------|----------------------------------------------|
| isNotValidXSS        | XSS 공격 문자열 검증                         |
| isNotValidSQL        | SQL Injection 문자열 검증                    |
| isNotOsCommandValid  | OS Command Injection 문자열 검증             |
| isHTTP_CWE113        | HTTP 응답분할(CRLF) 문자열 검증              |
| checkParam           | 파라미터별 화이트리스트/정규식 검증         |

---

### 2.5. 예외 및 메시지 계층

| 클래스명           | 설명                                           |
|--------------------|------------------------------------------------|
| DBException        | DB 계층 예외                                   |
| JEJBException      | EJB 계층 예외                                  |
| JServletException  | Servlet 계층 예외                              |
| UtilException      | 유틸리티 계층 예외                             |
| JException, Msg    | 시스템 표준 예외 및 메시지 관리                 |

---

## 3. 데이터 흐름 및 시퀀스

### 3.1. 업무 데이터 저장 시퀀스

```mermaid
sequenceDiagram
    participant WebClient as Web Client
    participant JSP as JSP/Servlet
    participant JRequest as JRequest
    participant SBCDA110EHome as SBCDA110EHome
    participant SBCDA110E as SBCDA110E
    participant SBCDA110EBean as SBCDA110EBean
    participant DBObjectManager as DBObjectManager
    participant DBObject as DBObject
    participant IDGen as IDGen
    participant DBConnManager as DBConnManager
    participant JConnection as JConnection
    participant JPreparedStatement as JPreparedStatement
    participant DB as Database

    WebClient->>JSP: 저장 요청 (폼 데이터)
    JSP->>JRequest: 파라미터 추출/검증
    JSP->>SBCDA110EHome: EJB Home lookup
    JSP->>SBCDA110E: create() 호출
    JSP->>SBCDA110E: saveRecord(GauceDataSet)
    SBCDA110E->>SBCDA110EBean: saveRecord(GauceDataSet)
    SBCDA110EBean->>DBObjectManager: getDBObject()
    DBObjectManager->>DBObject: setIDGen(IDGen)
    SBCDA110EBean->>DBObject: 데이터 저장 호출
    DBObject->>IDGen: getNextID(...)
    DBObject->>DBConnManager: getConnection()
    DBConnManager->>JConnection: 커넥션 획득
    JConnection->>JPreparedStatement: prepareStatement
    JPreparedStatement->>DB: SQL 실행
    DB-->>JPreparedStatement: 실행 결과
    JPreparedStatement-->>JConnection: 결과 반환
    JConnection-->>DBConnManager: 커넥션 반납
    DBObject-->>SBCDA110EBean: 저장 결과
    SBCDA110EBean-->>SBCDA110E: 결과 반환
    SBCDA110E-->>JSP: 결과 반환
    JSP-->>WebClient: 저장 결과 응답
```

### 3.2. 금융 Delegate → EJB 호출 시퀀스

```mermaid
sequenceDiagram
    participant Controller
    participant Delegate as FCBCDD160E
    participant EJB as SBCDD160E
    participant DB

    Controller->>+Delegate: searchRecord(정산사업자, 청구월, ...)
    Delegate->>+EJB: searchRecord(정산사업자, 청구월, ...)
    EJB->>+DB: 집계 쿼리 실행
    DB-->>-EJB: 집계 결과 반환
    EJB-->>-Delegate: GauceDataSet 반환
    Delegate-->>-Controller: GauceDataSet 반환
    Note over Delegate,EJB: 예외 발생 시 로그 기록 및 JException 변환
```

### 3.3. SRPT 통계 데이터 조회 시퀀스

```mermaid
sequenceDiagram
    participant Client as "Client(UI/Report)"
    participant Home as "SRPT_BCDF440EHome"
    participant Remote as "SRPT_BCDF440E"
    participant Bean as "SRPT_BCDF440EBean"
    participant DAO as "DAORPT_BCDF440E"
    participant DB as "DB"
    participant Gauce as "GauceDataSet"

    Client ->> Home: create()
    Home -->> Remote: SRPT_BCDF440E (Remote)
    Client ->> Remote: searchgraphRecord(hmParam)
    Remote ->> Bean: searchgraphRecord(hmParam)
    Bean ->> DAO: searchgraphRecord(hmParam)
    DAO ->> DB: SELECT ... (조건 기반 집계)
    DB -->> DAO: ResultSet
    DAO ->> Gauce: ResultSet -> GauceDataSet 변환
    Gauce -->> DAO: GauceDataSet
    DAO -->> Bean: GauceDataSet
    Bean -->> Remote: GauceDataSet
    Remote -->> Client: GauceDataSet
```

---

## 4. 데이터셋 및 API 요약

### 4.1. GauceDataSet 컬럼 예시

| 컬럼명           | 타입      | 설명               |
|------------------|----------|--------------------|
| CALL_START       | String   | 집계 기준(월/일)   |
| STD_USE_COUNT    | Decimal  | 표준 사용 건수     |
| MONTH_USE_COUNT  | Decimal  | 월별 사용 건수     |
| STD_USE_TIME     | Decimal  | 표준 사용 시간     |
| MONTH_USE_TIME   | Decimal  | 월별 사용 시간     |
| STD_USE_CHRG     | Decimal  | 표준 사용 요금     |
| MONTH_USE_CHRG   | Decimal  | 월별 사용 요금     |
| STD_USE_DOSU     | Decimal  | 표준 도수          |
| MONTH_USE_DOSU   | Decimal  | 월별 도수          |

### 4.2. 주요 API 및 파라미터

| 메서드명                | 파라미터 (타입)         | 반환값         | 설명                                 |
|------------------------|------------------------|---------------|--------------------------------------|
| searchRecord1          | String callTypeStd     | GauceDataSet  | 운송사/연도별 집계 조회              |
| searchRecord2          | ...                    | GauceDataSet  | 운송사/월별 집계 조회                |
| saveRecord             | GauceDataSet           | int           | 집계 데이터 등록/수정                |
| searchgraphRecord      | HashMap hmParam        | GauceDataSet  | 통계 데이터 집계 조회                |
| printRecord            | HashMap hmParam        | GauceDataSet  | 리포트용 데이터셋(Stub, 확장 가능)   |

#### searchgraphRecord 파라미터 예시

| 파라미터명         | 타입     | 설명                       |
|--------------------|----------|----------------------------|
| settle_carrier     | String   | 정산 사업자                |
| clg_carrier        | String   | 발신 사업자                |
| cld_carrier        | String   | 착신 사업자                |
| services           | String   | 서비스 코드                |
| chrg_item          | String   | 과금 항목                  |
| interval           | String   | 집계 단위(월/일)           |
| gubun              | String   | 검증/정산 구분             |
| call_type          | String   | 통화 유형                  |
| from_month         | String   | 조회 시작 월/일            |
| to_month           | String   | 조회 종료 월/일            |

---

## 5. 설계 품질 및 개선점

| 항목                   | 설명                                                                                   |
|------------------------|----------------------------------------------------------------------------------------|
| 관심사 분리            | Controller, Service, DAO, Infra 등 역할별로 명확히 분리                                |
| 표준화된 데이터셋      | GauceDataSet 기반으로 프론트엔드/리포트 시스템과의 연동 표준화                         |
| 동적 쿼리/파라미터화   | 다양한 통계 조건에 따라 동적으로 쿼리 생성 및 파라미터 바인딩                         |
| 트랜잭션/예외 관리      | EJB 컨테이너 및 JEJBException 등으로 안정적 트랜잭션/예외 처리                         |
| 확장성                 | Stub 메서드, HashMap 파라미터 등으로 향후 기능/조건/포맷 확장 용이                    |
| 분산 환경 지원         | EJBObject 상속, RemoteException 등으로 분산 시스템에서의 안정적 서비스 제공            |
| 타입 안전성 강화       | HashMap 파라미터 → DTO(전용 파라미터 객체)로 변경하여 컴파일 타임 타입 체크 강화        |
| 데이터셋 포맷 다양화   | GauceDataSet 외 JSON, DTO 등 다양한 포맷 지원                                          |
| 로깅/모니터링 강화     | 서비스 호출, 쿼리 성능, 예외 발생 등에 대한 로깅 및 모니터링 체계 강화                 |
| 테스트 용이성 강화     | 인터페이스 기반 설계, Mock 객체 주입 등으로 단위 테스트 자동화 가능                    |

---

## 결론

**업무 및 금융 모듈**은 EJB 기반의 비즈니스 로직 계층, Delegate/Facade 서비스 계층, 표준화된 DB 접근/ID 생성, 파일 입출력, 보안·입력값 검증, 프레젠테이션 계층 지원 유틸리티 등으로 구성된
엔터프라이즈급 백엔드 아키텍처입니다.
각 계층은 관심사의 분리, 표준화, 확장성, 보안성, 유지보수성을 고려하여 설계되어 있으며,
실제 운송사 집계, 금융 정산, 통계/리포트, 파일 업로드/다운로드, DB 트랜잭션, 입력값 검증 등 다양한 실무 요구를 안정적으로 지원합니다.

향후에는
- DI/전략 패턴 도입,
- 현대적 자바 기능 적용,
- 보안 정책 강화,
- 테스트 용이성 확보,
- API/데이터 포맷 다양화
등을 통해 더욱 견고하고 유연한 구조로 발전할 수 있습니다.

**이 모듈은 대규모 엔터프라이즈 시스템에서 업무 및 금융 로직의 안정성, 일관성, 확장성, 보안성을 책임지는 핵심 인프라로서,
실제 운영 환경에서의 다양한 요구에 효과적으로 대응할 수 있는 기반을 제공합니다.**', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('8b76510c-643d-4bf1-be47-8b9d174d9cb9', e'# 세션빈 기반 업무처리 모듈

## 소개

**세션빈 기반 업무처리 모듈**은 엔터프라이즈 자바 환경에서 운송사 청구/지불 집계, 파일 업로드/다운로드, DB 접근, 보안 유틸리티 등 다양한 업무를 표준화된 구조로 처리하기 위한 핵심 백엔드 아키텍처입니다.
이 모듈은 EJB(Session Bean) 기반의 비즈니스 로직 계층, DAO/DB 유틸리티, 파일 입출력, 보안·입력값 검증, 프레젠테이션 계층 지원 유틸리티 등으로 구성되어 있으며,
각 계층은 관심사의 분리, 표준화, 확장성, 보안성, 유지보수성을 극대화하도록 설계되어 있습니다.

아래는 전체 시스템의 주요 의존성 및 아키텍처 흐름을 나타낸 Mermaid.js 다이어그램입니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        JSP["JSP/Servlet"]
        JRequest["JRequest"]
        JSession["JSession"]
        JFileUpload["JFileUpload"]
        JFileDownload["JFileDownload"]
    end

    subgraph "Controller Layer"
        SBCDA110EHome["SBCDA110EHome"]
        SBCDA110E["SBCDA110E"]
    end

    subgraph "Service Layer"
        SBCDA110EBean["SBCDA110EBean"]
    end

    subgraph "Business/Domain Layer"
        DBObjectManager["DBObjectManager"]
        DBObject["DBObject"]
        FileInfo["FileInfo"]
        StructFile["StructFile"]
        JUploadedFile["JUploadedFile"]
    end

    subgraph "Data Access Layer"
        MaxIDGen["MaxIDGen"]
        SeqIDGen["SeqIDGen"]
        SPIDGen["SPIDGen"]
        IDGen["IDGen"]
        DBConnManager["DBConnManager"]
        DBConnPool["DBConnPool"]
        JConnection["JConnection"]
        JPreparedStatement["JPreparedStatement"]
        JResultSet["JResultSet"]
        JStatement["JStatement"]
    end

    subgraph "Utility/Configuration"
        Util["Util"]
        SQLUtil["SQLUtil"]
        JspUtil["JspUtil"]
        DBCodeConverter["DBCodeConverter"]
        StackTraceParser["StackTraceParser"]
        Configuration["Configuration"]
    end

    JSP --> JRequest
    JSP --> JFileUpload
    JSP --> JFileDownload
    JRequest --> JSession
    JRequest --> SBCDA110EHome
    SBCDA110EHome --> SBCDA110E
    SBCDA110E --> SBCDA110EBean
    SBCDA110EBean --> DBObjectManager
    DBObjectManager --> DBObject
    DBObject --> IDGen
    DBObject --> FileInfo
    JFileUpload --> FileInfo
    JFileUpload --> StructFile
    JFileUpload --> JUploadedFile
    JFileDownload --> FileInfo

    SBCDA110EBean --> DBConnManager
    DBConnManager --> DBConnPool
    DBConnPool --> JConnection
    JConnection --> JPreparedStatement
    JConnection --> JStatement
    JPreparedStatement --> JResultSet

    IDGen --> MaxIDGen
    IDGen --> SeqIDGen
    IDGen --> SPIDGen

    Util --> SQLUtil
    Util --> JspUtil
    Util --> DBCodeConverter
    Util --> StackTraceParser
    Util --> Configuration
```

**설명:**
- 프레젠테이션 계층(JSP/Servlet 등)에서 요청이 들어오면, JRequest, JSession, JFileUpload, JFileDownload 등 유틸리티를 통해 입력값 처리, 세션 관리, 파일 입출력 등을 수행합니다.
- 컨트롤러 계층(EJB Home/Remote 인터페이스)에서 비즈니스 로직 세션빈(SBCDA110EBean 등)을 호출합니다.
- 비즈니스 로직 계층에서는 DBObjectManager, DBObject, FileInfo 등 도메인 객체를 활용하며,
  데이터 접근 계층(IDGen, DBConnManager, JConnection 등)과 협력하여 DB 작업을 처리합니다.
- 유틸리티/설정 계층에서는 입력값 검증, SQL 생성, 문자셋 변환, 환경설정 등 공통 기능을 제공합니다.

---

# 상세 구성 및 역할

## 1. 비즈니스 로직 계층 (Session Bean)

### 1.1. SBCDA110EBean / SBCDA110E / SBCDA110EHome

- **SBCDA110EBean**: 운송사 청구/지불 집계 데이터의 조회 및 저장(등록/수정) 비즈니스 로직을 담당하는 세션 빈.
- **SBCDA110E**: 원격 인터페이스(EJBObject)로, 클라이언트가 호출할 수 있는 표준 서비스 계약을 정의.
- **SBCDA110EHome**: 홈 인터페이스(EJBHome)로, 세션 빈 인스턴스의 생성 및 생명주기 관리 담당.

#### 주요 메서드

| 메서드명         | 설명                                   | 입출력/예외         |
|------------------|----------------------------------------|---------------------|
| searchRecord1    | 운송사/연도별 청구/지불 집계 조회      | GauceDataSet, JEJBException |
| searchRecord2    | 운송사/월별 청구/지불 집계 조회        | GauceDataSet, JEJBException |
| saveRecord       | 집계 데이터 등록/수정(트랜잭션 처리)    | int, JEJBException  |

#### 코드 예시

```java
public GauceDataSet searchRecord1(String callTypeStd) throws JEJBException {
    return daoBCDA110E.searchRecord1(callTypeStd);
}
```

---

## 2. 데이터 접근 계층 (DAO/IDGen/DBConn)

### 2.1. IDGen 및 구현체

| 클래스명      | 설명                                         |
|---------------|----------------------------------------------|
| IDGen         | ID 생성 정책 인터페이스 (MAX, SEQ, SP 지원)  |
| MaxIDGen      | 테이블 최대값+1 방식 ID 생성                  |
| SeqIDGen      | 오라클 시퀀스 기반 ID 생성                   |
| SPIDGen       | 저장 프로시저 기반 ID 생성                   |

#### IDGen 인터페이스

| 메서드명      | 파라미터                       | 반환값   | 설명                |
|---------------|-------------------------------|----------|---------------------|
| getNextID     | name, targetName, whereCond   | String   | 다음 ID 생성        |

#### 예시

```java
public String getNextID(String name, String targetName, String whereCondition) throws DBException {
    // 예: SELECT my_seq.nextval FROM dual
}
```

### 2.2. DBConnManager/DBConnPool/JConnection

- **DBConnManager**: DB 커넥션 풀 관리의 중앙 진입점. 환경설정에 따라 적합한 DBConnPool 구현체를 동적으로 로딩.
- **DBConnPool**: 커넥션 풀 인터페이스. JConnection, Connection 획득/반납 지원.
- **JConnection**: JDBC Connection 래퍼. 트랜잭션, Statement/PreparedStatement 생성, 예외 처리 등 제공.

#### DBConnManager 예시

```java
public static JConnection getConnection() throws DBException {
    if(dbcp == null)
        throw new DBException("DBConnPool object is null. Check error log.");
    return dbcp.getConnection();
}
```

---

## 3. DB 유틸리티 계층

### 3.1. JPreparedStatement/JResultSet/JStatement

- **JPreparedStatement**: JDBC PreparedStatement 래퍼. 파라미터 관리, 예외 처리, 로깅, 성능 모니터링 등 제공.
- **JResultSet**: JDBC ResultSet 래퍼. 데이터 추출, 타입 변환, 예외 처리, 코드 변환 등 제공.
- **JStatement**: JDBC Statement 래퍼. SQL 실행, 예외 처리, 로깅 등 제공.

#### JPreparedStatement 예시

```java
public void setString(int parameterIndex, String x) throws DBException {
    stmt.setString(parameterIndex, converter.convertDataToDBData(x));
    params.put(new Integer(parameterIndex), "\'" + x + "\'");
}
```

---

## 4. 파일 입출력 계층

### 4.1. JFileUpload/JFileDownload/FileInfo/StructFile/JUploadedFile

- **JFileUpload**: HTTP 멀티파트 파일 업로드 처리. 파일 저장, 파라미터 추출, 경로/파일명 관리 등.
- **JFileDownload**: 파일 다운로드 Servlet. 세션 체크, 파일 경로/이름 처리, 스트림 전송, 예외 처리 등.
- **FileInfo**: 파일 메타데이터 DTO. 파일명, 경로, 확장자, 크기, 등록/수정일 등 관리.
- **StructFile**: 업로드 파일의 경로, 파일명, 필드명 등 구조화 정보 관리.
- **JUploadedFile**: 업로드 파일 단위의 정보 및 상태 관리(VO).

#### FileInfo 필드 요약

| 필드명            | 타입     | 설명                    |
|-------------------|----------|-------------------------|
| fileId            | String   | 파일 식별자             |
| uniqueFileName    | String   | 고유 파일명(중복 방지)  |
| fileCategory      | String   | 파일 분류               |
| relativePath      | String   | 상대 경로               |
| fileName          | String   | 원본 파일명             |
| fileExt           | String   | 파일 확장자             |
| fileSize          | String   | 파일 크기               |
| useyn             | String   | 사용 여부               |
| regdt/upddt       | Date     | 등록/수정일             |
| absolutePath      | String   | 전체 경로               |

---

## 5. 유틸리티/보안/입력값 검증 계층

### 5.1. Util/SQLUtil/JspUtil/DBCodeConverter/StackTraceParser

- **Util**: 범용 데이터 변환, 입력값 검증, 보안(XSS/SQL Injection/OS Command Injection/HTTP Response Splitting), 환경설정 등.
- **SQLUtil**: 검색 조건 파싱, 동적 SQL 생성, PreparedStatement 파라미터 바인딩 등.
- **JspUtil**: URL 인코딩/디코딩, HTML 변환, 콤보박스/페이징 UI 생성 등 JSP/Servlet 지원.
- **DBCodeConverter**: 문자셋 변환(애플리케이션 ↔ DB), 인코딩 불일치 해결.
- **StackTraceParser**: 예외 스택 트레이스 파싱, 호출자/오너 클래스 추출 등.

#### Util 주요 보안 메서드

| 메서드명             | 설명                                         |
|----------------------|----------------------------------------------|
| isNotValidXSS        | XSS 공격 문자열 검증                         |
| isNotValidSQL        | SQL Injection 문자열 검증                    |
| isNotOsCommandValid  | OS Command Injection 문자열 검증             |
| isHTTP_CWE113        | HTTP 응답분할(CRLF) 문자열 검증              |
| checkParam           | 파라미터별 화이트리스트/정규식 검증         |

---

## 6. 예외 및 메시지 계층

- **DBException, JEJBException, JServletException, UtilException**: 각 계층별 커스텀 예외 클래스.
  예외 메시지, 코드, 원인 예외, 메시지 객체(Msg) 등 다양한 정보를 구조화하여 전달.

---

# 데이터 흐름 및 시퀀스 예시

아래는 운송사 집계 데이터 저장(saveRecord) 시 전체 계층의 호출 흐름을 나타낸 시퀀스 다이어그램입니다.

```mermaid
sequenceDiagram
    participant WebClient as Web Client
    participant JSP as JSP/Servlet
    participant JRequest as JRequest
    participant SBCDA110EHome as SBCDA110EHome
    participant SBCDA110E as SBCDA110E
    participant SBCDA110EBean as SBCDA110EBean
    participant DBObjectManager as DBObjectManager
    participant DBObject as DBObject
    participant IDGen as IDGen
    participant DBConnManager as DBConnManager
    participant JConnection as JConnection
    participant JPreparedStatement as JPreparedStatement
    participant DB as Database

    WebClient->>JSP: 저장 요청 (폼 데이터)
    JSP->>JRequest: 파라미터 추출/검증
    JSP->>SBCDA110EHome: EJB Home lookup
    JSP->>SBCDA110E: create() 호출
    JSP->>SBCDA110E: saveRecord(GauceDataSet)
    SBCDA110E->>SBCDA110EBean: saveRecord(GauceDataSet)
    SBCDA110EBean->>DBObjectManager: getDBObject()
    DBObjectManager->>DBObject: setIDGen(IDGen)
    SBCDA110EBean->>DBObject: 데이터 저장 호출
    DBObject->>IDGen: getNextID(...)
    DBObject->>DBConnManager: getConnection()
    DBConnManager->>JConnection: 커넥션 획득
    JConnection->>JPreparedStatement: prepareStatement
    JPreparedStatement->>DB: SQL 실행
    DB-->>JPreparedStatement: 실행 결과
    JPreparedStatement-->>JConnection: 결과 반환
    JConnection-->>DBConnManager: 커넥션 반납
    DBObject-->>SBCDA110EBean: 저장 결과
    SBCDA110EBean-->>SBCDA110E: 결과 반환
    SBCDA110E-->>JSP: 결과 반환
    JSP-->>WebClient: 저장 결과 응답
```

---

# 주요 테이블/구성요소 요약

## 1. 비즈니스 서비스 인터페이스

| 컴포넌트         | 설명                                           |
|------------------|------------------------------------------------|
| SBCDA110EBean    | 운송사 집계 데이터 비즈니스 로직 세션 빈        |
| SBCDA110E        | EJB 원격 인터페이스                            |
| SBCDA110EHome    | EJB 홈 인터페이스                              |

## 2. DB 접근/ID 생성

| 컴포넌트         | 설명                                           |
|------------------|------------------------------------------------|
| DBConnManager    | 커넥션 풀 관리, 커넥션 획득/반납                |
| DBConnPool       | 커넥션 풀 인터페이스                            |
| JConnection      | JDBC Connection 래퍼                            |
| JPreparedStatement| PreparedStatement 래퍼                         |
| IDGen            | ID 생성 정책 인터페이스                         |
| MaxIDGen         | 테이블 MAX+1 방식                               |
| SeqIDGen         | 오라클 시퀀스 방식                              |
| SPIDGen          | 저장 프로시저 방식                              |

## 3. 파일 입출력

| 컴포넌트         | 설명                                           |
|------------------|------------------------------------------------|
| JFileUpload      | 파일 업로드 처리, 파일 저장/파싱                |
| JFileDownload    | 파일 다운로드 Servlet                           |
| FileInfo         | 파일 메타데이터 DTO                             |
| StructFile       | 업로드 파일 구조 정보 DTO                       |
| JUploadedFile    | 업로드 파일 단위 정보 VO                        |

## 4. 유틸리티/보안

| 컴포넌트         | 설명                                           |
|------------------|------------------------------------------------|
| Util             | 범용 데이터 변환, 보안, 환경설정 등             |
| SQLUtil          | 검색 조건 파싱, 동적 SQL 생성                   |
| JspUtil          | JSP/Servlet 지원, 콤보박스/페이징 등            |
| DBCodeConverter  | 문자셋 변환                                     |
| StackTraceParser | 예외 스택 트레이스 파싱                         |

---

# 결론

**세션빈 기반 업무처리 모듈**은 EJB 기반의 비즈니스 로직 계층, 표준화된 DB 접근/ID 생성, 파일 입출력, 보안·입력값 검증, 프레젠테이션 계층 지원 유틸리티 등으로 구성된
엔터프라이즈급 백엔드 아키텍처입니다.
각 계층은 관심사의 분리, 표준화, 확장성, 보안성, 유지보수성을 고려하여 설계되어 있으며,
실제 운송사 집계 업무, 파일 업로드/다운로드, DB 트랜잭션, 입력값 검증 등 다양한 실무 요구를 안정적으로 지원합니다.

향후에는
- DI/전략 패턴 도입,
- 현대적 자바 기능 적용,
- 보안 정책 강화,
- 테스트 용이성 확보,
- API/데이터 포맷 다양화
등을 통해 더욱 견고하고 유연한 구조로 발전할 수 있습니다.

**이 모듈은 대규모 엔터프라이즈 시스템에서 업무 로직의 안정성, 일관성, 확장성, 보안성을 책임지는 핵심 인프라로서,
실제 운영 환경에서의 다양한 요구에 효과적으로 대응할 수 있는 기반을 제공합니다.**', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('5d3f00ea-01bb-430e-a420-8c492b976bc0', e'# 금융코어시스템 기능 모듈

## 소개

금융코어시스템의 기능 모듈은 EJB(Enterprise JavaBeans) 기반의 분산 아키텍처에서, 다양한 비즈니스 도메인(정산, 통계, 배치, 코드관리 등)의 서비스 기능을 안전하고 일관되게 제공하는 **서비스 계층(Delegate/Facade/Proxy)** 컴포넌트 집합입니다.
이 모듈들은 클라이언트(웹, API, 배치 등)와 실제 비즈니스 로직(EJB Session Bean) 사이의 중간 계층으로 동작하며,
- EJB 원격 호출의 복잡성 은닉
- 예외 및 로깅의 표준화
- 데이터셋 반환 포맷의 통일
- 서비스 호출의 일관성 및 확장성
을 핵심 목표로 설계되었습니다.

아래는 전체 시스템의 주요 의존성 흐름을 나타낸 아키텍처 다이어그램입니다.

**아키텍처 다이어그램**

아래 다이어그램은 금융코어시스템 기능 모듈의 주요 레이어와 클래스 간 호출 흐름을 시각화한 것입니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        P1["Web Controller"]
        P2["Batch Scheduler"]
        P3["API Gateway"]
    end
    subgraph "Service Layer"
        S1["FCBCDB110E"]
        S2["FCBCDB120E"]
        S3["FCBCDD160E"]
        S4["FCBCDF330E"]
        S5["FCBCDG710E"]
        S6["FCBCDF720E"]
        S7["FCBCDD320E"]
        S8["FCBCDE390E"]
        S9["FCBCDF3E0E"]
        S10["FCBCDV140E"]
        S11["FCBCDV260E"]
        S12["FCBCDF650E"]
        S13["FCBCDH220E"]
        S14["FCBCDC340E"]
        S15["FCBCDA420E"]
        S16["FCBCDD140E"]
        S17["FCBCDD230E"]
        S18["FCBCDD430E"]
        S19["FCBCDF3D0E"]
        S20["FCBCDV250E"]
        S21["FCBCDH130E"]
        S22["FCBCDH310E"]
        S23["FCBCDD131E"]
        S24["FCBCDD191E"]
        S25["FCBCDE330E"]
        S26["FCBCDF861E"]
        S27["FCBCDD620E"]
        S28["FCBCDV320E"]
        S29["FCBCDC170E"]
        S30["FCBCDC260E"]
        S31["FCBCDB250E"]
        S32["FCBCDB160E"]
        S33["FCBCDB280E"]
        S34["FCBCDZB10E"]
        S35["FCRPT_BCDF540E"]
    end
    subgraph "Business Layer"
        B1["SBCDB110E"]
        B2["SBCDB120E"]
        B3["SBCDD160E"]
        B4["SBCDF330E"]
        B5["SBCDG710E"]
        B6["SBCDF720E"]
        B7["SBCDD320E"]
        B8["SBCDE390E"]
        B9["SBCDF3E0E"]
        B10["SBCDV140E"]
        B11["SBCDV260E"]
        B12["SBCDF650E"]
        B13["SBCDH220E"]
        B14["SBCDC340E"]
        B15["SBCDA420E"]
        B16["SBCDD140E"]
        B17["SBCDD230E"]
        B18["SBCDD430E"]
        B19["SBCDF3D0E"]
        B20["SBCDV250E"]
        B21["SBCDH130E"]
        B22["SBCDH310E"]
        B23["SBCDD131E"]
        B24["SBCDD191E"]
        B25["SBCDE330E"]
        B26["SBCDF861E"]
        B27["SBCDD620E"]
        B28["SBCDV320E"]
        B29["SBCDC170E"]
        B30["SBCDC260E"]
        B31["SBCDB250E"]
        B32["SBCDB160E"]
        B33["SBCDB280E"]
        B34["SBCDZB10E"]
        B35["SRPT_BCDF540E"]
    end
    subgraph "Data Access Layer"
        D1["DB/외부시스템"]
    end

    P1 --> S1
    P1 --> S2
    P1 --> S3
    P1 --> S4
    P1 --> S5
    P1 --> S6
    P1 --> S7
    P1 --> S8
    P1 --> S9
    P1 --> S10
    P1 --> S11
    P1 --> S12
    P1 --> S13
    P1 --> S14
    P1 --> S15
    P1 --> S16
    P1 --> S17
    P1 --> S18
    P1 --> S19
    P1 --> S20
    P1 --> S21
    P1 --> S22
    P1 --> S23
    P1 --> S24
    P1 --> S25
    P1 --> S26
    P1 --> S27
    P1 --> S28
    P1 --> S29
    P1 --> S30
    P1 --> S31
    P1 --> S32
    P1 --> S33
    P1 --> S34
    P1 --> S35

    P2 --> S1
    P2 --> S6
    P2 --> S35

    P3 --> S34

    S1 --> B1
    S2 --> B2
    S3 --> B3
    S4 --> B4
    S5 --> B5
    S6 --> B6
    S7 --> B7
    S8 --> B8
    S9 --> B9
    S10 --> B10
    S11 --> B11
    S12 --> B12
    S13 --> B13
    S14 --> B14
    S15 --> B15
    S16 --> B16
    S17 --> B17
    S18 --> B18
    S19 --> B19
    S20 --> B20
    S21 --> B21
    S22 --> B22
    S23 --> B23
    S24 --> B24
    S25 --> B25
    S26 --> B26
    S27 --> B27
    S28 --> B28
    S29 --> B29
    S30 --> B30
    S31 --> B31
    S32 --> B32
    S33 --> B33
    S34 --> B34
    S35 --> B35

    B1 --> D1
    B2 --> D1
    B3 --> D1
    B4 --> D1
    B5 --> D1
    B6 --> D1
    B7 --> D1
    B8 --> D1
    B9 --> D1
    B10 --> D1
    B11 --> D1
    B12 --> D1
    B13 --> D1
    B14 --> D1
    B15 --> D1
    B16 --> D1
    B17 --> D1
    B18 --> D1
    B19 --> D1
    B20 --> D1
    B21 --> D1
    B22 --> D1
    B23 --> D1
    B24 --> D1
    B25 --> D1
    B26 --> D1
    B27 --> D1
    B28 --> D1
    B29 --> D1
    B30 --> D1
    B31 --> D1
    B32 --> D1
    B33 --> D1
    B34 --> D1
    B35 --> D1
```
*설명: 각 Service Layer 클래스(FCBC*E 등)는 Presentation Layer(Controller 등)에서 호출되며, 내부적으로 Business Layer(EJB)로 위임합니다. Business Layer는 최종적으로 Data Access Layer(DB 등)와 연동합니다.*

---

# 주요 기능 모듈별 구조 및 역할

## 1. 서비스 계층(Delegate/Facade) 구조

### 아키텍처 개요

```mermaid
graph TD
    subgraph "Presentation Layer"
        C["Controller/Action"]
    end
    subgraph "Service Layer"
        S["FCBCDD160E 등 (Delegate/Facade)"]
    end
    subgraph "Business Layer"
        B["SBCDD160E 등 (EJB Session Bean)"]
    end
    subgraph "Data Access Layer"
        D["DB/외부시스템"]
    end
    C --> S
    S --> B
    B --> D
```
*설명: Controller는 Delegate/Facade(Service Layer)를 통해 비즈니스 기능을 호출하며, Delegate/Facade는 EJB Session Bean에 실제 처리를 위임합니다.*

---

## 2. 대표 기능 모듈별 상세

### 2.1. 조회/저장 Delegate 클래스 패턴

#### 코드 예시 (FCBCDD160E)

```java
public class FCBCDD160E
{
    SBCDD160E remoteSBCDD160EBean = null;

    public FCBCDD160E()
    {
        try {
            remoteSBCDD160EBean = (SBCDD160E) EJBUtil.getRemote("com_kt_icbs_SBCDD160EBean");
        } catch (Exception ex) {
            Log.err.println(ex, "fc - FCBCDD160E: constructor");
        }
    }

    public GauceDataSet searchRecord(String strSettleCarrier, String strBillMonth,
        String strTrafficMonthStart, String strTrafficMonthEnd, String strOption ) throws JException
    {
        try {
            return remoteSBCDD160EBean.searchRecord(strSettleCarrier, strBillMonth,
                strTrafficMonthStart, strTrafficMonthEnd, strOption);
        } catch (RemoteException ex) {
            Log.err.println(ex, "fc - FCBCDD160E: searchRecord()");
            throw new JException(ex, new Msg("MBCDZ001"));
        }
    }
    // ... (기타 메서드 동일 패턴)
}
```

#### 기능 요약 테이블

| 메서드명           | 주요 역할                        | 입력 파라미터                  | 반환값         | 예외 처리 방식      |
|-------------------|----------------------------------|-------------------------------|---------------|-------------------|
| searchRecord      | 정산/청구 데이터 조회            | 정산사업자, 청구월, 기간 등    | GauceDataSet  | JException 래핑   |
| getSettleCarrier  | 정산사업자 목록 조회             | 없음                          | GauceDataSet  | JException 래핑   |
| getBillMonth      | 청구년월 목록 조회               | 정산사업자                    | GauceDataSet  | JException 래핑   |
| getReportMaster   | 마스터 데이터 조회               | 정산사업자, 청구월, 기간 등    | GauceDataSet  | JException 래핑   |
| getReportDetail   | 상세 데이터 조회                 | 정산사업자, 청구월, 항목 등    | GauceDataSet  | JException 래핑   |

---

### 2.2. 게시판/코드/통계 등 특화 Delegate

#### 예시: 게시판 Delegate (FCBCDG710E)

| 메서드명           | 주요 역할                        | 입력 파라미터                  | 반환값         |
|-------------------|----------------------------------|-------------------------------|---------------|
| searchRecord      | 게시글 목록/검색 조회            | HashMap, 검색조건 등           | GauceDataSet  |
| deleteRecord      | 게시글/첨부파일 삭제             | GauceDataSet                  | int           |
| getUsedSQL        | SQL 추적(디버깅용)               | 없음                          | String        |

#### 예시: 코드/마스터 데이터 Delegate (FCBCDZB10E)

| 메서드명           | 주요 역할                        | 입력 파라미터                  | 반환값         |
|-------------------|----------------------------------|-------------------------------|---------------|
| getService_cdA/B/C| 공통 코드 조회                   | 구분, 추가옵션                 | GauceDataSet  |
| getCarrier_type   | 운송사 유형 코드 조회            | 추가옵션                       | GauceDataSet  |

---

### 2.3. 통계/집계 Delegate

#### 예시: 통계 Delegate (FCBCDF3E0E)

| 메서드명               | 주요 역할                        | 입력 파라미터                  | 반환값         |
|-----------------------|----------------------------------|-------------------------------|---------------|
| searchTelDayRecord    | 전화국별 일별 통계 조회           | HashMap                       | GauceDataSet  |
| searchTelMonthRecord  | 전화국별 월별 통계 조회           | HashMap                       | GauceDataSet  |
| searchAreaDayRecord   | 지역별 일별 통계 조회             | 여러 String                   | GauceDataSet  |
| searchAreaMonthRecord | 지역별 월별 통계 조회             | 여러 String                   | GauceDataSet  |

---

## 3. 공통 예외 및 로깅 정책

- 모든 Delegate 클래스는 EJB 호출 시 RemoteException을 캐치하여,
  시스템 표준 예외(JException)로 변환 후 상위 계층에 throw합니다.
- 예외 메시지는 공통 메시지 코드(MBCDZ001)로 통일되어 장애 추적이 용이합니다.
- 예외 발생 시 로그(Log.err.println 등)를 남겨 운영 및 장애 분석에 활용합니다.

---

## 4. 데이터셋 표준화

- 모든 데이터 반환은 GauceDataSet 등 프레임워크 표준 데이터 구조로 통일되어,
  프론트엔드/서비스/API 등 다양한 계층에서 일관된 방식으로 데이터 활용이 가능합니다.

---

## 5. 대표 시퀀스 다이어그램

아래는 Controller에서 Delegate(Service Layer)를 통해 EJB 비즈니스 로직을 호출하는 일반적인 흐름을 나타냅니다.

```mermaid
sequenceDiagram
    participant Controller
    participant Delegate as FCBCDD160E
    participant EJB as SBCDD160E
    participant DB

    Controller->>+Delegate: searchRecord(정산사업자, 청구월, ...)
    Delegate->>+EJB: searchRecord(정산사업자, 청구월, ...)
    EJB->>+DB: 집계 쿼리 실행
    DB-->>-EJB: 집계 결과 반환
    EJB-->>-Delegate: GauceDataSet 반환
    Delegate-->>-Controller: GauceDataSet 반환
    Note over Delegate,EJB: 예외 발생 시 로그 기록 및 JException 변환
```

---

## 6. 공통 클래스/컴포넌트 요약

| 클래스명           | 주요 역할 및 설명                                  |
|-------------------|---------------------------------------------------|
| FCBCDD160E 등     | Delegate/Facade. EJB 호출 캡슐화, 예외/로깅 표준화 |
| SBCDD160E 등      | EJB Session Bean. 실제 비즈니스 로직 구현          |
| EJBUtil           | EJB 객체 lookup 유틸리티                           |
| Log               | 시스템 로그 기록 유틸리티                           |
| JException, Msg   | 시스템 표준 예외 및 메시지 관리                     |
| GauceDataSet      | 데이터셋 표준 포맷(프레임워크 의존)                |

---

## 7. 대표 Delegate 클래스 구조 요약

```java
public class FCBCDD160E
{
    SBCDD160E remoteSBCDD160EBean = null;

    public FCBCDD160E()
    {
        try {
            remoteSBCDD160EBean = (SBCDD160E) EJBUtil.getRemote("com_kt_icbs_SBCDD160EBean");
        } catch (Exception ex) {
            Log.err.println(ex, "fc - FCBCDD160E: constructor");
        }
    }

    public GauceDataSet searchRecord(String strSettleCarrier, String strBillMonth, ...) throws JException
    {
        try {
            return remoteSBCDD160EBean.searchRecord(strSettleCarrier, strBillMonth, ...);
        } catch (RemoteException ex) {
            Log.err.println(ex, "fc - FCBCDD160E: searchRecord()");
            throw new JException(ex, new Msg("MBCDZ001"));
        }
    }
    // ... 기타 메서드 동일 패턴
}
```

---

## 8. 개선점 및 확장성

- **DI(Dependency Injection) 적용**: EJB 객체를 직접 lookup하지 않고, DI 프레임워크(Spring 등)로 주입받으면 테스트 용이성 및 유연성이 향상됩니다.
- **JNDI 이름 외부화**: 하드코딩된 JNDI 이름을 설정 파일/환경 변수로 분리하여 환경별 배포 유연성 확보
- **예외 처리 고도화**: 예외 유형별 상세 메시지, 사용자 친화적 메시지, 장애 복구 정책 등 적용 가능
- **로깅 표준화**: SLF4J, Log4j 등 표준 로깅 프레임워크 적용
- **데이터셋 포맷 다양화**: GauceDataSet 외 JSON, DTO 등 다양한 포맷 지원
- **테스트 용이성 강화**: 인터페이스 기반 설계, Mock 객체 주입 등으로 단위 테스트 자동화 가능
- **확장성**: 새로운 비즈니스 메서드 추가, 다양한 EJB 지원, 파라미터/반환 타입 확장 등 구조적 확장 용이

---

## 결론

금융코어시스템의 기능 모듈(Delegate/Facade 계층)은
- **EJB 기반 비즈니스 로직 호출의 표준화, 안정성, 일관성**을 보장하며,
- **예외/로깅/데이터셋 반환 정책의 중앙 집중화**를 실현합니다.
- **프레젠테이션 계층과 EJB 비즈니스 계층의 결합도를 낮추고**,
- **시스템의 유지보수성과 확장성을 높이는 핵심 역할**을 담당합니다.

향후 DI, 로깅, 예외 처리, 데이터셋 추상화 등 아키텍처적 개선을 통해
더 견고하고 유연한 서비스 계층으로 발전시킬 수 있습니다.

**즉, 금융코어시스템 기능 모듈은 엔터프라이즈 시스템에서
"비즈니스 로직 호출의 관문"이자,
"표준화된 서비스 인터페이스"로서 핵심적인 역할을 담당합니다.**', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('bf31f06b-5110-41b3-b518-219c0406917c', e'# SRPT 보고서 세션빈 모듈

## 소개

**SRPT 보고서 세션빈 모듈**은 통신 과금/정산 시스템에서 통계성 데이터(통화량, 통화시간 등)의 집계 및 리포트 데이터셋 생성을 위한 EJB 기반의 비즈니스 로직 계층을 구성합니다.
이 모듈은 다양한 통계 조건(사업자, 통화유형, 기간 등)에 따라 데이터를 동적으로 집계하고,
GauceDataSet 포맷으로 결과를 반환하여 프론트엔드(웹 UI, 리포트 시스템 등)와의 연동을 표준화합니다.

전체 시스템에서 SRPT 세션빈 계층은
- 프레젠테이션 계층(웹/리포트)과
- 데이터 액세스 계층(DAO)
사이의 **비즈니스 서비스 게이트웨이**로 동작하며,
분산 환경에서 안정적이고 확장 가능한 통계 데이터 서비스를 제공합니다.

아래는 전체 시스템의 의존성 흐름을 나타낸 아키텍처 다이어그램입니다.

**아키텍처 다이어그램**

SRPT 보고서 세션빈 모듈의 주요 흐름은 다음과 같습니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        UI["웹 UI/리포트"]
    end
    subgraph "Controller Layer"
        Controller["SRPT_BCDF440EHome\\n(EJB Home)"]
    end
    subgraph "Service Layer"
        Service["SRPT_BCDF440EBean\\n(Session Bean)"]
        Interface["SRPT_BCDF440E\\n(EJB Remote Interface)"]
    end
    subgraph "Data Access Layer"
        DAO["DAORPT_BCDF440E\\n(DAO)"]
    end
    subgraph "Domain/Infra Layer"
        DB["DB\\n(TB_230 등)"]
        Gauce["GauceDataSet\\n(포맷)"]
    end

    UI --> Controller
    Controller --> Interface
    Interface --> Service
    Service --> DAO
    DAO --> DB
    Service --> Gauce
    DAO --> Gauce
```
*설명: 프론트엔드(UI)는 EJB Home(Controller Layer)을 통해 Remote Interface를 호출하고,
Session Bean(Service Layer)이 DAO(Data Access Layer)와 협력하여 DB에서 데이터를 조회/가공합니다.
모든 결과는 GauceDataSet 포맷으로 표준화되어 반환됩니다.*

---

## 주요 구성요소 및 역할

### 1. EJB Home/Remote/Session Bean

| 구성요소                | 역할 요약                                                                                   |
|------------------------|---------------------------------------------------------------------------------------------|
| **SRPT_BCDF440EHome**  | EJB 세션빈의 생성 및 생명주기 관리 (팩토리/진입점, JNDI 네이밍)                              |
| **SRPT_BCDF440E**      | 비즈니스 서비스(통계 조회 등) 원격 호출 인터페이스 (EJBObject 상속)                          |
| **SRPT_BCDF440EBean**  | 실제 비즈니스 로직 구현체. DAO 호출, 데이터셋 가공, 트랜잭션/예외 관리 등                    |

### 2. DAO 계층

| 클래스명                | 주요 역할                                                         |
|------------------------|-------------------------------------------------------------------|
| **DAORPT_BCDF440E**    | 실제 DB 쿼리 실행, 집계, GauceDataSet 변환 등 데이터 접근/가공 책임 |

### 3. GauceDataSet

- 데이터셋 표준 포맷.
- 프론트엔드, 리포트 시스템과의 데이터 교환을 위한 핵심 구조체.

### 4. 예외/유틸리티

| 클래스명                | 주요 역할                                                         |
|------------------------|-------------------------------------------------------------------|
| **JEJBException**      | EJB 환경에서의 예외 래핑/전달                                      |
| **EJBUtil**            | EJB 객체 조회, JNDI, 예외 처리 등 유틸리티                         |
| **JSessionBean**       | EJB SessionBean 생명주기 관리 기본 클래스                          |

---

## 상세 구조 및 데이터 흐름

### 1. EJB 인터페이스/세션빈 구조

#### SRPT_BCDF440E (Remote Interface)

- **searchgraphRecord(HashMap hmParam): GauceDataSet**
    - 다양한 조건(사업자, 통화유형, 기간 등)으로 통계 데이터 집계
    - GauceDataSet 반환

- **printRecord(HashMap hmParam): GauceDataSet**
    - 리포트용 데이터셋 생성(Stub, 향후 확장 가능)

#### SRPT_BCDF440EBean (Session Bean)

- **daoRPT_BCDF440E**: DAO 객체 멤버
- **searchgraphRecord**: DAO의 searchgraphRecord 위임 호출
- **printRecord**: DAO의 printRecord 위임 호출

```java
public GauceDataSet searchgraphRecord(HashMap hmParam) throws JEJBException {
    return daoRPT_BCDF440E.searchgraphRecord(hmParam);
}
```

#### SRPT_BCDF440EHome (Home Interface)

- EJB 세션빈 인스턴스 생성 및 JNDI 네이밍 제공

---

### 2. 데이터 흐름 시퀀스

아래는 통계 데이터 조회 요청의 시퀀스 다이어그램입니다.

```mermaid
sequenceDiagram
    participant Client as "Client(UI/Report)"
    participant Home as "SRPT_BCDF440EHome"
    participant Remote as "SRPT_BCDF440E"
    participant Bean as "SRPT_BCDF440EBean"
    participant DAO as "DAORPT_BCDF440E"
    participant DB as "DB"
    participant Gauce as "GauceDataSet"

    Client ->> Home: create()
    Home -->> Remote: SRPT_BCDF440E (Remote)
    Client ->> Remote: searchgraphRecord(hmParam)
    Remote ->> Bean: searchgraphRecord(hmParam)
    Bean ->> DAO: searchgraphRecord(hmParam)
    DAO ->> DB: SELECT ... (조건 기반 집계)
    DB -->> DAO: ResultSet
    DAO ->> Gauce: ResultSet -> GauceDataSet 변환
    Gauce -->> DAO: GauceDataSet
    DAO -->> Bean: GauceDataSet
    Bean -->> Remote: GauceDataSet
    Remote -->> Client: GauceDataSet
```
*설명: 클라이언트는 EJB Home을 통해 Remote 인터페이스를 획득하고,
searchgraphRecord를 호출하면, Bean이 DAO를 통해 DB에서 데이터를 조회/가공하여
GauceDataSet으로 반환합니다.*

---

### 3. DAO 계층 및 데이터셋 구조

#### DAORPT_BCDF440E (예시)

```java
public GauceDataSet searchgraphRecord(HashMap hmParam) throws JEJBException {
    // 1. 파라미터 추출
    // 2. 동적 쿼리 생성 및 실행
    // 3. ResultSet -> GauceDataSet 변환
    // 4. 반환
}
```

#### GauceDataSet 반환 예시

| 컬럼명           | 타입      | 설명               |
|------------------|----------|--------------------|
| CALL_START       | String   | 집계 기준(월/일)   |
| STD_USE_COUNT    | Decimal  | 표준 사용 건수     |
| MONTH_USE_COUNT  | Decimal  | 월별 사용 건수     |
| ...              | ...      | ...                |

---

## API/데이터셋 요약

### 주요 API 및 파라미터

| 메서드명                | 파라미터 (타입)         | 반환값         | 설명                                 |
|------------------------|------------------------|---------------|--------------------------------------|
| searchgraphRecord      | HashMap hmParam        | GauceDataSet  | 통계 데이터 집계 조회                |
| printRecord            | HashMap hmParam        | GauceDataSet  | 리포트용 데이터셋(Stub, 확장 가능)   |

#### searchgraphRecord 파라미터 예시

| 파라미터명         | 타입     | 설명                       |
|--------------------|----------|----------------------------|
| settle_carrier     | String   | 정산 사업자                |
| clg_carrier        | String   | 발신 사업자                |
| cld_carrier        | String   | 착신 사업자                |
| services           | String   | 서비스 코드                |
| chrg_item          | String   | 과금 항목                  |
| interval           | String   | 집계 단위(월/일)           |
| gubun              | String   | 검증/정산 구분             |
| call_type          | String   | 통화 유형                  |
| from_month         | String   | 조회 시작 월/일            |
| to_month           | String   | 조회 종료 월/일            |

---

### GauceDataSet 컬럼 예시

| 컬럼명           | 타입      | 설명               |
|------------------|----------|--------------------|
| CALL_START       | String   | 집계 기준(월/일)   |
| STD_USE_COUNT    | Decimal  | 표준 사용 건수     |
| MONTH_USE_COUNT  | Decimal  | 월별 사용 건수     |
| STD_USE_TIME     | Decimal  | 표준 사용 시간     |
| MONTH_USE_TIME   | Decimal  | 월별 사용 시간     |
| STD_USE_CHRG     | Decimal  | 표준 사용 요금     |
| MONTH_USE_CHRG   | Decimal  | 월별 사용 요금     |
| STD_USE_DOSU     | Decimal  | 표준 도수          |
| MONTH_USE_DOSU   | Decimal  | 월별 도수          |

---

## 데이터 흐름 및 아키텍처 요약 다이어그램

아래는 SRPT 보고서 세션빈 모듈의 전체 아키텍처 및 데이터 흐름을 요약한 다이어그램입니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        UI["웹 UI/리포트"]
    end
    subgraph "Controller Layer"
        Home["SRPT_BCDF440EHome"]
    end
    subgraph "Service Layer"
        Remote["SRPT_BCDF440E (Remote)"]
        Bean["SRPT_BCDF440EBean"]
    end
    subgraph "Data Access Layer"
        DAO["DAORPT_BCDF440E"]
    end
    subgraph "Domain/Infra Layer"
        DB["DB"]
        Gauce["GauceDataSet"]
    end

    UI --> Home
    Home --> Remote
    Remote --> Bean
    Bean --> DAO
    DAO --> DB
    Bean --> Gauce
    DAO --> Gauce
```
*설명: 각 레이어는 역할별로 분리되어 있으며,
데이터 흐름은 프론트엔드 → EJB Home → Remote Interface → Session Bean → DAO → DB로 이어집니다.
모든 결과는 GauceDataSet 포맷으로 표준화되어 반환됩니다.*

---

## 주요 설계 품질 및 특징

| 항목                   | 설명                                                                                   |
|------------------------|----------------------------------------------------------------------------------------|
| 관심사 분리            | Controller, Service, DAO, Infra 등 역할별로 명확히 분리                                |
| 표준화된 데이터셋      | GauceDataSet 기반으로 프론트엔드/리포트 시스템과의 연동 표준화                         |
| 동적 쿼리/파라미터화   | 다양한 통계 조건에 따라 동적으로 쿼리 생성 및 파라미터 바인딩                         |
| 트랜잭션/예외 관리      | EJB 컨테이너 및 JEJBException 등으로 안정적 트랜잭션/예외 처리                         |
| 확장성                 | Stub 메서드, HashMap 파라미터 등으로 향후 기능/조건/포맷 확장 용이                    |
| 분산 환경 지원         | EJBObject 상속, RemoteException 등으로 분산 시스템에서의 안정적 서비스 제공            |

---

## 개선점 및 확장성

| 개선/확장 항목         | 설명                                                                                   |
|------------------------|----------------------------------------------------------------------------------------|
| 타입 안전성 강화       | HashMap 파라미터 → DTO(전용 파라미터 객체)로 변경하여 컴파일 타임 타입 체크 강화        |
| GauceDataSet 추상화    | 내부적으로는 GauceDataSet 사용, 외부에는 DTO/JSON 등 다양한 포맷 지원 가능              |
| printRecord 구현       | Stub 메서드에 실제 리포트 데이터셋 생성/가공 로직 추가                                 |
| 입력값 검증 강화       | 필수 파라미터 누락, 잘못된 값 입력 시 명확한 예외 및 에러 메시지 제공                  |
| 로깅/모니터링 강화     | 서비스 호출, 쿼리 성능, 예외 발생 등에 대한 로깅 및 모니터링 체계 강화                 |
| 조회 조건/결과 확장    | 새로운 필터, 집계 단위, 결과 컬럼 등 유연하게 확장 가능                                |
| 다양한 데이터 포맷 지원| GauceDataSet 외에 JSON, XML, DTO 등 다양한 포맷으로 결과 변환 가능                    |
| 비동기 처리/캐싱       | 대용량 데이터 조회 시 비동기 처리, 결과 캐싱 등 성능 최적화 가능                       |

---

## 결론

**SRPT 보고서 세션빈 모듈**은
- 통화 통계 및 리포트 데이터셋 서비스를 표준화된 방식으로 제공하는
- EJB 기반 비즈니스 로직 계층의 핵심 컴포넌트입니다.

- 다양한 통계 조건에 따라 동적으로 데이터를 집계하고,
- 프론트엔드/리포트 시스템에서 바로 활용 가능한 데이터셋을 제공합니다.

- 유연성(동적 파라미터, Stub 제공),
- 표준화(GauceDataSet 반환),
- 확장성(새로운 조건/기능 추가 용이)
등의 장점을 가지며,

- 타입 안정성 부족,
- 프레임워크 종속성,
- 미구현 메서드 존재
등의 개선 여지도 있습니다.

시스템 전체에서
**비즈니스 서비스 게이트웨이**로서
데이터 액세스 계층과 프레젠테이션 계층을 연결하는
핵심 역할을 수행하며,

향후
- 타입 안전성 강화,
- 데이터셋 추상화,
- 리포트 기능 구현,
- 성능/확장성 개선
등을 통해
더 견고하고 유연한 통계/리포트 서비스로 발전할 수 있습니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('4aca96ef-8792-4468-a92e-a9ef8dd81418', e'# 데이터 처리 및 통신

## 소개

데이터 처리 및 통신 모듈은 대규모 데이터의 수집, 전처리, 분석, 저장, 그리고 웹 기반 요청/응답의 표준화된 처리를 통합적으로 지원하는 핵심 계층입니다. 본 모듈은 데이터 파이프라인(수집→처리→저장)과 웹 애플리케이션의 요청/응답, 파라미터 검증, 세션/파일/예외/로깅/보안 등 실무적 요구를 일관성 있게 처리하여, 시스템의 품질과 확장성을 보장합니다.

전체 시스템은 Presentation, Business, Data Access, Domain, Configuration, Utility, Exception/Logging 등 역할별로 명확히 분리되어 있으며, 각 계층은 독립적이면서도 유기적으로 협력하여 데이터 처리 및 통신의 모든 흐름을 지원합니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 주요 레이어와 의존성 흐름을 시각적으로 나타냅니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        Controller["DataController"]
        JFileUpload["JFileUpload"]
        JFileDownload["JFileDownload"]
        JRequest["JRequest"]
        ICBSRequest["ICBSRequest"]
        JSession["JSession"]
        ICBSSession["ICBSSession"]
    end
    subgraph "Business Layer"
        DataService["DataService"]
        ServiceManager["Service/Manager"]
    end
    subgraph "Data Access Layer"
        DataRepository["DataRepository"]
        Repository["Repository/DAO"]
        CodeManager["CodeManager"]
        ScreenManager["ScreenManager"]
    end
    subgraph "Domain Layer"
        DataModel["DataModel"]
        FileInfo["FileInfo"]
        StructFile["StructFile"]
        JUploadedFile["JUploadedFile"]
        ComENT["ComENT"]
        Screen["Screen"]
        ICBSStructSession["ICBSStructSession"]
        PagedList["PagedList"]
    end
    subgraph "Configuration Layer"
        AppConfig["AppConfig"]
        Configuration["Configuration"]
        Const["Const"]
        JProperties["JProperties"]
    end
    subgraph "Utility Layer"
        Util["Util"]
        ICBSUtil["ICBSUtil"]
        SQLUtil["SQLUtil"]
        JspUtil["JspUtil"]
        Base64Util["Base64Util"]
        AES256Util["AES256Util"]
        AES256Util2["AES256Util2"]
        ICBSEncoder["ICBSEncoder"]
    end
    subgraph "Exception/Logging Layer"
        JException["JException"]
        JServletException["JServletException"]
        Msg["Msg"]
        Log["Log"]
        FileLogger["FileLogger"]
        FileLoggerIF["FileLoggerIF"]
    end

    Controller --> DataService
    Controller --> AppConfig
    Controller --> JFileUpload
    Controller --> JFileDownload
    Controller --> JRequest
    Controller --> JSession
    Controller --> ICBSRequest
    Controller --> ICBSSession

    DataService --> DataRepository
    DataService --> ServiceManager
    DataService --> AppConfig
    DataService --> Configuration

    DataRepository --> DataModel
    DataRepository --> FileInfo
    DataRepository --> StructFile
    DataRepository --> JUploadedFile
    DataRepository --> ComENT
    DataRepository --> Screen
    DataRepository --> ICBSStructSession
    DataRepository --> PagedList
    DataRepository --> CodeManager
    DataRepository --> ScreenManager

    JFileUpload --> FileInfo
    JFileUpload --> StructFile
    JFileUpload --> JUploadedFile
    JFileUpload --> Util
    JFileUpload --> Configuration

    JFileDownload --> FileInfo
    JFileDownload --> Util
    JFileDownload --> Configuration

    JRequest --> ICBSRequest
    JRequest --> JSession
    JRequest --> Util

    JSession --> ICBSSession
    ICBSSession --> ICBSStructSession

    AppConfig --> Configuration
    AppConfig --> Const
    AppConfig --> JProperties

    Util --> Base64Util
    Util --> AES256Util
    Util --> AES256Util2
    Util --> ICBSEncoder
    Util --> SQLUtil
    Util --> JspUtil

    JException --> JServletException
    JException --> Msg
    Log --> FileLogger
    FileLogger --> FileLoggerIF
```

위 다이어그램은 각 계층의 역할과 데이터/통신 흐름을 명확하게 보여줍니다.

---

## 1. 프레젠테이션 계층: 요청/응답 및 파일 처리

### 1.1. 요청 래퍼 및 파라미터 처리

#### 주요 클래스 및 역할

| 클래스명         | 주요 역할 및 설명 |
|------------------|------------------|
| DataController   | 외부 요청 수신, 입력 검증, 응답 반환 |
| JRequest         | HttpServletRequest 래핑, 파라미터 인코딩/변환, 세션 관리, 파라미터→객체 매핑 |
| ICBSRequest      | JRequest 확장, 환경설정 기반 인코딩/파라미터 처리, Return URL 관리, 세션(ICBSSession) 관리 |
| JMultipartRequest| 멀티파트 폼 파라미터 관리, 인코딩 변환, 파라미터 저장/조회 |

#### 파라미터 인코딩 및 자동 매핑 예시

```java
public String getParameter(String name) {
    String param = request.getParameter(name);
    if(param == null) return "";
    if(only_8859_1) {
        String retParam = "";
        try {
            retParam = new String(param.getBytes(Const.CHARSET_8859_1));
        } catch(UnsupportedEncodingException ex) {
        } finally {
            return retParam;
        }
    } else {
        return param;
    }
}
```

```java
public Object mapToObject(Class target) throws JServletException {
    try {
        Object obj = target.newInstance();
        Enumeration enu = getParameterNames();
        Method[] methods = target.getMethods();
        while(enu.hasMoreElements()) {
            // ... setter 탐색 및 타입 변환 생략
            setter.invoke(obj, params);
        }
        return obj;
    } catch(Exception ex) {
        throw new JServletException("Failed to map a request to object: " + ex.getMessage());
    }
}
```

---

### 1.2. 세션 관리

| 클래스명      | 주요 역할 및 설명 |
|---------------|------------------|
| JSession      | HttpSession 래핑, 세션 속성 관리, 만료/유효성 검사, 예외 처리 |
| ICBSSession   | HttpSession 래핑, ICBSStructSession 관리, 세션 라이프사이클/정책 적용 |
| ICBSStructSession | 사용자 인증/상태/OTP 등 세션 구조체, 세션 바인딩 이벤트 처리 |

```java
public void setAttribute(String name, Object obj) throws JServletException {
    checkValidSession();
    if(name == null || name.equals(""))
        throw new JServletException("Parameter \'name\' can not be null or \\"\\".");
    session.setAttribute(name, obj);
}
```

---

### 1.3. 파일 업로드/다운로드

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| JFileUpload     | 멀티파트 파일 업로드 파싱/저장, 파일 메타데이터 관리, 파라미터 추출 |
| JFileDownload   | 파일 다운로드 서블릿, 세션/인증/경로/브라우저 호환성 처리 |
| FileInfo        | 파일 메타데이터 DTO (ID, 이름, 경로, 크기, 확장자 등) |
| JUploadedFile   | 업로드 파일 단위 정보 VO (이름, 경로, 크기, Content-Type 등) |
| StructFile      | 업로드 파일의 경로/이름/필드명 구조화 DTO |

```java
public FileInfo[] upload(String fileCategory) throws JServletException {
    // ... 업로드 경로/정책 결정
    return save(fileDir.toString(), PHYSICAL, fileCategory, relativePath);
}
```

```java
public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // ... 세션/인증/경로/브라우저 처리
    bout = new BufferedOutputStream(response.getOutputStream(), 4096);
    bin = new BufferedInputStream(new FileInputStream(filepath), 4096);
    // ... 파일 스트림 전송
}
```

---

### 1.4. 예외 및 메시지 처리

| 클래스명            | 주요 역할 및 설명 |
|---------------------|------------------|
| JServletException   | 서블릿 계층 예외, 코드/메시지/Msg 객체 등 구조화 |
| JException          | 시스템 공통 예외, 래핑/코드/메시지/원인 예외 관리 |
| JMailException      | 메일 처리 예외 |
| Msg                 | 메시지 객체 (코드, 다국어, 상세 설명 등) |

```java
public JServletException(int code, String exMsg, Msg msg) {
    super(code, exMsg, msg);
}
```

---

## 2. 비즈니스/데이터/도메인/설정/유틸리티 계층

### 2.1. 비즈니스 로직 및 데이터 처리

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| DataService     | 비즈니스 로직 처리, 데이터 전처리/분석/변환 |
| DataRepository  | 데이터 저장소 입출력, CRUD 기능 |
| CodeManager     | 코드 테이블 중앙 관리, 코드명/표시명/관계코드/다국어/콤보박스 생성 등 |
| ScreenManager   | 화면 정의(XML) 중앙 관리, 동적 로딩/캐싱, 다국어 지원 |
| PagedList       | 페이징 데이터 컨테이너, 페이징 UI 생성 지원 |

```java
public String getCodeName(String code) {
    Object obj = getObject(code);
    if(obj == null) return "";
    String[] data = (String[])obj;
    return data[NAME];
}
```

---

### 2.2. 환경설정 및 상수 관리

| 클래스명                | 주요 역할 및 설명 |
|-------------------------|------------------|
| AppConfig               | 환경설정 및 시스템 구성 정보 제공 |
| Configuration           | 환경설정(프로퍼티) 중앙 관리, 타입별 조회/예외처리/동적 리프레시 |
| Const                   | 시스템 전역 상수 집합 (DBMS, 인코딩, 언어, 환경설정 키 등) |
| JProperties             | 프로퍼티 확장, 타입 안전 조회/저장/예외처리/객체 저장 등 |
| ConfigurationException  | 설정 계층 예외 |
| JPropertiesException    | 프로퍼티 계층 예외 |

```java
public static String getString(String name, String defaultStr) {
    refresh();
    String ret = "";
    try {
        ret = prop.getString(name);
    } catch(JPropertiesException ex) {
        ret = defaultStr;
    }
    return ret;
}
```

---

### 2.3. 공통 유틸리티 및 보안

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| Util            | 범용 유틸리티(데이터 변환, 입력값 검증, 보안, 환경, DB 등) |
| ICBSUtil        | 업무 특화 유틸리티(날짜/문자열/한글/보안 등) |
| SQLUtil         | SQL 동적 생성, 파라미터 바인딩, 검색 조건 파싱/검증 등 |
| JspUtil         | JSP/Servlet UI 유틸리티(인코딩, 콤보박스, 페이징 등) |
| Base64Util      | Base64 인코딩/디코딩/Reverse 등 |
| AES256Util/AES256Util2 | AES256 암호화/복호화, 환경설정 기반 키/IV 관리 |
| ICBSEncoder     | 커스텀 인코딩/디코딩, 중복 인코딩 관리 등 |

```java
public static String filter(String oldStr) {
    if (oldStr == null) return null;
    StringBuffer result = new StringBuffer(oldStr.length());
    for (int i=0; i<oldStr.length(); ++i) {
        switch (oldStr.charAt(i)) {
            case \'<\': result.append("&lt;"); break;
            // ... 생략
            default: result.append(oldStr.charAt(i)); break;
        }
    }
    return result.toString();
}
```

---

### 2.4. 메시지/로깅/예외/파일/세션/메일/JMS

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| Msg             | 메시지 객체(코드, 다국어, 상세 설명 등) |
| Log             | 시스템 로깅 유틸리티 |
| FileLogger/FileLoggerIF | 파일 기반 로깅, 로그 타입/파일명/경로 상수 등 |
| JMail           | 메일 송수신, 첨부파일/인코딩 등 지원 |
| JMSMsgSender/Receiver | JMS 메시지 송수신, 큐/세션/예외/로깅 등 관리 |

---

## 3. 데이터/도메인 계층

### 3.1. 데이터 객체 및 구조체

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| DataModel       | 데이터 구조 및 도메인 속성 정의 |
| FileInfo        | 파일 메타데이터 DTO (ID, 이름, 경로, 크기, 확장자 등) |
| JUploadedFile   | 업로드 파일 단위 정보 VO (이름, 경로, 크기, Content-Type 등) |
| StructFile      | 업로드 파일의 경로/이름/필드명 구조화 DTO |
| ComENT          | 대량 파라미터 집합 관리 VO/DTO |
| Screen          | 화면 단위 데이터 컨테이너(블록/타입) |
| ICBSStructSession | 세션 구조체, 사용자 인증/상태/OTP 등 관리 |
| PagedList       | 페이징 데이터 컨테이너, 페이징 UI 생성 지원 |

---

## 4. 데이터 흐름 시퀀스 다이어그램

### 4.1. 데이터 처리 요청

아래 시퀀스 다이어그램은 데이터가 컨트롤러에서 시작하여 저장소에 저장되기까지의 전체 흐름을 보여줍니다.

```mermaid
sequenceDiagram
    participant Client as Client
    participant Controller as DataController
    participant Service as DataService
    participant Repository as DataRepository
    participant Model as DataModel
    participant Config as AppConfig

    Client ->> Controller: 데이터 처리 요청
    activate Controller
    Controller ->> Config: 환경설정 조회
    Controller ->> Service: 요청 데이터 전달
    activate Service
    Service ->> Config: 환경설정 조회
    Service ->> Repository: 데이터 저장 요청
    activate Repository
    Repository ->> Config: 환경설정 조회
    Repository ->> Model: 데이터 모델 변환
    Repository -->> Service: 저장 결과 반환
    deactivate Repository
    Service -->> Controller: 처리 결과 반환
    deactivate Service
    Controller -->> Client: 응답 반환
    deactivate Controller
    Note over Controller,Service: 각 단계에서 유효성 검사 및 예외 처리 수행
```

### 4.2. 파일 업로드 처리

```mermaid
sequenceDiagram
    participant Client as 웹 브라우저
    participant Controller as JFileUpload
    participant Request as JRequest
    participant FileInfo as FileInfo
    participant Util as Util
    participant Config as Configuration

    Client->>+Controller: multipart/form-data 파일 업로드 요청
    Controller->>+Request: 파라미터/파일 추출
    Request-->>-Controller: 파라미터/파일 데이터
    Controller->>+Config: 업로드 경로/정책 조회
    Config-->>-Controller: 업로드 경로/정책
    Controller->>+Util: 인코딩/파일명 변환 등
    Util-->>-Controller: 변환 결과
    Controller->>+FileInfo: 파일 메타데이터 생성
    FileInfo-->>-Controller: FileInfo[]
    Controller-->>-Client: 업로드 결과 응답
    deactivate Controller
```

---

## 5. 데이터 모델/구성 요약

### 5.1. 데이터 모델 필드

| 필드명     | 타입     | 제약조건    | 설명                  |
|------------|----------|-------------|-----------------------|
| id         | String   | Primary Key | 데이터 고유 식별자    |
| value      | Float    | Not Null    | 측정값 또는 데이터 값 |
| timestamp  | DateTime | Not Null    | 데이터 생성 시각      |

### 5.2. FileInfo 주요 필드

| 필드명           | 타입     | 설명                      |
|------------------|----------|---------------------------|
| fileId           | String   | 파일 ID (PK 조합)         |
| uniqueFileName   | String   | 고유 파일명(타임스탬프)   |
| fileCategory     | String   | 파일 분류                 |
| relativePath     | String   | 상대 경로                 |
| fileName         | String   | 원본 파일명               |
| fileExt          | String   | 파일 확장자               |
| fileSize         | String   | 파일 크기                 |
| useyn            | String   | 사용 여부                 |
| regdt            | Date     | 등록일                    |
| upddt            | Date     | 수정일                    |
| oldUniqueFileName| String   | 이전 파일명               |
| absolutePath     | String   | 전체 경로                 |

---

## 6. API/파라미터/설정 요약

### 6.1. API 엔드포인트

| 엔드포인트         | 메서드 | 파라미터          | 타입     | 설명                    |
|--------------------|--------|-------------------|----------|-------------------------|
| /data/process      | POST   | data              | JSON     | 데이터 처리 요청        |
| /data/{id}         | GET    | id                | String   | 특정 데이터 조회        |
| /data/{id}         | DELETE | id                | String   | 특정 데이터 삭제        |

### 6.2. JFileUpload 주요 메서드

| 메서드명            | 파라미터/타입           | 설명                                 |
|---------------------|-------------------------|--------------------------------------|
| upload              | fileCategory, structFile| 파일 업로드 및 저장                  |
| saveAs              | uploadDir, timeStamp    | 지정 경로에 파일 저장                |
| getFileCount        | 없음                    | 업로드된 파일 개수 반환              |
| getFile             | name or index           | 업로드 파일 객체 반환                |
| getParameter        | name                    | 폼 파라미터 값 반환                  |
| setMaxFileSize      | maxFileSize             | 파일 크기 제한 설정                  |

### 6.3. 환경설정 항목

| 설정명               | 타입     | 기본값      | 설명                        |
|----------------------|----------|-------------|-----------------------------|
| DB_CONNECTION_STRING | String   | (미정)      | 데이터베이스 연결 문자열    |
| API_KEY              | String   | (미정)      | 외부 API 인증 키            |
| LOG_LEVEL            | String   | INFO        | 로그 출력 레벨              |

---

## 결론

데이터 처리 및 통신 모듈은 명확한 계층 구조와 역할 분담을 통해 데이터의 수집, 처리, 저장, 그리고 웹 요청/응답의 표준화 및 보안/예외/로깅 등 실무적 요구를 체계적으로 지원합니다. 각 계층은 독립적으로 설계되어 유지보수와 확장이 용이하며, 환경설정과 데이터 모델 정의를 통해 다양한 비즈니스 요구사항에 유연하게 대응할 수 있습니다. 본 문서는 실제 소스 구조와 흐름을 기반으로, 개발자들이 시스템을 빠르게 이해하고 효과적으로 활용할 수 있도록 작성되었습니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('857a610e-3876-45ad-84eb-ec0f87974c8b', e'# 가우스 데이터 처리 패키지

## 소개

가우스 데이터 처리 패키지는 대규모 데이터의 수집, 전처리, 분석 및 저장을 효율적으로 지원하기 위해 설계된 소프트웨어 구성 요소입니다. 이 패키지는 다양한 데이터 소스에서 데이터를 받아, 비즈니스 로직을 통해 처리한 후, 데이터 저장소에 안전하게 저장하는 전체 파이프라인을 제공합니다.

본 패키지는 Presentation Layer, Business Layer, Data Layer, Domain Layer, Configuration Layer 등으로 구성되어 있으며, 각 레이어는 명확한 역할 분담을 통해 시스템의 확장성과 유지보수성을 높이고 있습니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 주요 레이어와 그 흐름을 시각적으로 나타냅니다.

아키텍처 다이어그램:

```mermaid
graph TD
    subgraph "Presentation Layer"
        Controller["DataController"]
    end
    subgraph "Business Layer"
        Service["DataService"]
    end
    subgraph "Data Access Layer"
        Repository["DataRepository"]
    end
    subgraph "Domain Layer"
        Model["DataModel"]
    end
    subgraph "Configuration Layer"
        Config["AppConfig"]
    end
    Controller --> Service
    Service --> Repository
    Repository --> Model
    Controller --> Config
    Service --> Config
    Repository --> Config
```

위 다이어그램은 각 레이어의 역할과 데이터 흐름을 명확하게 보여줍니다.

---

## 주요 구성 요소 및 역할

### Presentation Layer

#### DataController

- 외부 요청을 받아들이고, 비즈니스 로직 처리를 위해 Service Layer로 위임합니다.
- 입력 데이터의 유효성 검사 및 응답 반환을 담당합니다.

### Business Layer

#### DataService

- 데이터 처리의 핵심 비즈니스 로직을 구현합니다.
- 데이터 전처리, 분석, 변환 등의 주요 기능을 수행합니다.
- DataRepository를 호출하여 데이터의 저장 및 조회를 담당합니다.

### Data Access Layer

#### DataRepository

- 데이터베이스 또는 외부 저장소와의 직접적인 입출력을 담당합니다.
- CRUD(생성, 조회, 수정, 삭제) 기능을 제공합니다.

### Domain Layer

#### DataModel

- 데이터의 구조와 속성을 정의합니다.
- 비즈니스 도메인에 맞는 데이터 타입, 제약조건 등을 포함합니다.

### Configuration Layer

#### AppConfig

- 시스템 전반에 걸친 환경설정 및 구성 정보를 제공합니다.
- 데이터베이스 연결 정보, 외부 API 키, 기타 환경 변수 등을 관리합니다.

---

## 데이터 흐름 시퀀스 다이어그램

아래 시퀀스 다이어그램은 데이터가 컨트롤러에서 시작하여 저장소에 저장되기까지의 전체 흐름을 보여줍니다.

```mermaid
sequenceDiagram
    participant Client as Client
    participant Controller as DataController
    participant Service as DataService
    participant Repository as DataRepository
    participant Model as DataModel
    participant Config as AppConfig

    Client ->> Controller: 데이터 처리 요청
    activate Controller
    Controller ->> Config: 환경설정 조회
    Controller ->> Service: 요청 데이터 전달
    activate Service
    Service ->> Config: 환경설정 조회
    Service ->> Repository: 데이터 저장 요청
    activate Repository
    Repository ->> Config: 환경설정 조회
    Repository ->> Model: 데이터 모델 변환
    Repository -->> Service: 저장 결과 반환
    deactivate Repository
    Service -->> Controller: 처리 결과 반환
    deactivate Service
    Controller -->> Client: 응답 반환
    deactivate Controller
    Note over Controller,Service: 각 단계에서 유효성 검사 및 예외 처리 수행
```

---

## 주요 컴포넌트 요약

| 컴포넌트         | 역할 및 설명                                    |
|------------------|------------------------------------------------|
| DataController   | 외부 요청 수신, 입력 검증, 응답 반환            |
| DataService      | 비즈니스 로직 처리, 데이터 전처리/분석/변환     |
| DataRepository   | 데이터 저장소 입출력, CRUD 기능                 |
| DataModel        | 데이터 구조 및 도메인 속성 정의                 |
| AppConfig        | 환경설정 및 시스템 구성 정보 제공               |

---

## API 엔드포인트 요약

| 엔드포인트         | 메서드 | 파라미터          | 타입     | 설명                    |
|--------------------|--------|-------------------|----------|-------------------------|
| /data/process      | POST   | data              | JSON     | 데이터 처리 요청        |
| /data/{id}         | GET    | id                | String   | 특정 데이터 조회        |
| /data/{id}         | DELETE | id                | String   | 특정 데이터 삭제        |

---

## 데이터 모델 필드 요약

| 필드명     | 타입     | 제약조건    | 설명                  |
|------------|----------|-------------|-----------------------|
| id         | String   | Primary Key | 데이터 고유 식별자    |
| value      | Float    | Not Null    | 측정값 또는 데이터 값 |
| timestamp  | DateTime | Not Null    | 데이터 생성 시각      |

---

## 환경설정 항목

| 설정명               | 타입     | 기본값      | 설명                        |
|----------------------|----------|-------------|-----------------------------|
| DB_CONNECTION_STRING | String   | (미정)      | 데이터베이스 연결 문자열    |
| API_KEY              | String   | (미정)      | 외부 API 인증 키            |
| LOG_LEVEL            | String   | INFO        | 로그 출력 레벨              |

---

## 결론

가우스 데이터 처리 패키지는 명확한 계층 구조와 역할 분담을 통해 데이터의 수집, 처리, 저장을 체계적으로 지원합니다. 각 레이어는 독립적으로 설계되어 유지보수와 확장이 용이하며, 환경설정과 데이터 모델 정의를 통해 다양한 비즈니스 요구사항에 유연하게 대응할 수 있습니다. 본 문서는 패키지의 구조와 주요 흐름을 시각적으로 설명하여, 개발자들이 시스템을 빠르게 이해하고 효과적으로 활용할 수 있도록 돕습니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('eca923c9-5bf7-4b52-a95a-c423ce783b7e', e'# 서블릿 및 필터 처리 모듈

---

## 소개

**서블릿 및 필터 처리 모듈**은 웹 애플리케이션에서 HTTP 요청/응답의 표준화된 처리, 입력 파라미터의 검증 및 인코딩, 세션/파일/예외/로깅/보안 등 실무적 요구를 일관성 있게 지원하는 핵심 계층입니다.
이 모듈은 요청/응답의 흐름 제어, 파라미터 자동 매핑, 세션 관리, 파일 업로드/다운로드, 예외 및 메시지 처리, 환경설정, 공통 유틸리티 등 다양한 역할을 담당하며,
전체 시스템의 품질, 보안, 확장성, 유지보수성을 보장하는 기반을 제공합니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 주요 레이어와 각 역할별 의존성 흐름을 시각적으로 보여줍니다.

**아키텍처 다이어그램 설명:**
- Presentation Layer(Controller/Servlet)에서 요청을 받아,
- Business(Service) Layer로 전달하며,
- Data Access Layer(Repository/DAO)와 연동,
- Domain Layer(VO/DTO/Entity)와 데이터 변환,
- Configuration/Utility/Exception/Logging 등 공통 모듈과 협력합니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        A["JFileDownload"]
        B["FileLoader"]
        C["JFileUpload"]
        D["JRequest"]
        E["ICBSRequest"]
        F["JSession"]
        G["ICBSSession"]
        H["JMultipartRequest"]
        I["JServletException"]
        J["JMailException"]
        K["JMSMsgSender"]
        L["JMSMsgReceiver"]
    end
    subgraph "Business Layer"
        M["Service/Manager"]
    end
    subgraph "Data Access Layer"
        N["Repository/DAO"]
        O["CodeManager"]
        P["ScreenManager"]
    end
    subgraph "Domain Layer"
        Q["FileInfo"]
        R["StructFile"]
        S["JUploadedFile"]
        T["ComENT"]
        U["Screen"]
        V["ICBSStructSession"]
        W["PagedList"]
    end
    subgraph "Configuration Layer"
        X["Configuration"]
        Y["Const"]
        Z["JProperties"]
        AA["ConfigurationException"]
        AB["JPropertiesException"]
    end
    subgraph "Utility Layer"
        AC["Util"]
        AD["ICBSUtil"]
        AE["SQLUtil"]
        AF["JspUtil"]
        AG["Base64Util"]
        AH["AES256Util"]
        AI["AES256Util2"]
        AJ["ICBSEncoder"]
    end
    subgraph "Exception/Logging Layer"
        AK["JException"]
        AL["Msg"]
        AM["Log"]
        AN["FileLogger"]
        AO["FileLoggerIF"]
    end

    %% Flow
    A --> D
    B --> D
    C --> D
    D --> F
    D --> Q
    D --> M
    D --> X
    D --> AC
    D --> AK
    D --> AL
    D --> AM
    D --> I
    D --> J
    D --> H
    D --> S
    D --> Q
    D --> R
    D --> W
    D --> T
    D --> U
    D --> V
    D --> Y
    D --> Z
    D --> AA
    D --> AB
    D --> AG
    D --> AH
    D --> AI
    D --> AJ
    D --> AN
    D --> AO

    E --> G
    E --> V
    E --> M
    E --> X
    E --> AC
    E --> AK
    E --> AL
    E --> AM
    E --> I
    E --> J
    E --> H
    E --> S
    E --> Q
    E --> R
    E --> W
    E --> T
    E --> U
    E --> V
    E --> Y
    E --> Z
    E --> AA
    E --> AB
    E --> AG
    E --> AH
    E --> AI
    E --> AJ
    E --> AN
    E --> AO

    F --> V
    G --> V
    M --> N
    M --> O
    M --> P
    N --> Q
    N --> R
    N --> S
    N --> T
    N --> U
    N --> V
    N --> W
    O --> Q
    P --> U
    X --> Z
    X --> Y
    X --> AA
    X --> AB
    AC --> AE
    AC --> AF
    AC --> AG
    AC --> AH
    AC --> AI
    AC --> AJ
    AK --> I
    AK --> J
    AK --> AA
    AK --> AB
    AL --> AK
    AM --> AN
    AM --> AO
```

---

## 1. 프레젠테이션 계층: 요청/응답 및 파일 처리

### 1.1. 요청 래퍼 및 파라미터 처리

#### 주요 클래스 및 역할

| 클래스명         | 주요 역할 및 설명 |
|------------------|------------------|
| JRequest         | HttpServletRequest 래핑, 파라미터 인코딩/변환, 세션 관리, 파라미터→객체 매핑 |
| ICBSRequest      | JRequest 확장, 환경설정 기반 인코딩/파라미터 처리, Return URL 관리, 세션(ICBSSession) 관리 |
| JMultipartRequest| 멀티파트 폼 파라미터 관리, 인코딩 변환, 파라미터 저장/조회 |

#### 데이터 흐름 및 구조

- 요청 파라미터를 읽어올 때 인코딩 정책(8859_1 등)에 따라 자동 변환
- 파라미터 이름/값을 안전하게 저장 및 조회
- 파라미터 → 객체 자동 매핑(mapToObject) 지원

```java
// JRequest 파라미터 인코딩 처리 예시
public String getParameter(String name) {
    String param = request.getParameter(name);
    if(param == null) return "";
    if(only_8859_1) {
        String retParam = "";
        try {
            retParam = new String(param.getBytes(Const.CHARSET_8859_1));
        } catch(UnsupportedEncodingException ex) {
        } finally {
            return retParam;
        }
    } else {
        return param;
    }
}
```

#### 파라미터 자동 매핑

```java
// JRequest mapToObject 예시
public Object mapToObject(Class target) throws JServletException {
    try {
        Object obj = target.newInstance();
        Enumeration enu = getParameterNames();
        Method[] methods = target.getMethods();
        while(enu.hasMoreElements()) {
            // ... setter 탐색 및 타입 변환 생략
            setter.invoke(obj, params);
        }
        return obj;
    } catch(Exception ex) {
        throw new JServletException("Failed to map a request to object: " + ex.getMessage());
    }
}
```

---

### 1.2. 세션 관리

#### 주요 클래스 및 역할

| 클래스명      | 주요 역할 및 설명 |
|---------------|------------------|
| JSession      | HttpSession 래핑, 세션 속성 관리, 만료/유효성 검사, 예외 처리 |
| ICBSSession   | HttpSession 래핑, ICBSStructSession 관리, 세션 라이프사이클/정책 적용 |
| ICBSStructSession | 사용자 인증/상태/OTP 등 세션 구조체, 세션 바인딩 이벤트 처리 |

#### 세션 관리 흐름

- 세션 객체를 래핑하여 직접 접근 차단, 유효성 검사 및 예외 처리 일관화
- 세션 속성의 안전한 저장/조회/삭제, 만료/생성/ID/타임아웃 등 정책 적용

```java
// JSession 세션 속성 관리 예시
public void setAttribute(String name, Object obj) throws JServletException {
    checkValidSession();
    if(name == null || name.equals(""))
        throw new JServletException("Parameter \'name\' can not be null or \\"\\".");
    session.setAttribute(name, obj);
}
```

---

### 1.3. 파일 업로드/다운로드

#### 주요 클래스 및 역할

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| JFileUpload     | 멀티파트 파일 업로드 파싱/저장, 파일 메타데이터 관리, 파라미터 추출 |
| JFileDownload   | 파일 다운로드 서블릿, 세션/인증/경로/브라우저 호환성 처리 |
| FileInfo        | 파일 메타데이터 DTO (ID, 이름, 경로, 크기, 확장자 등) |
| JUploadedFile   | 업로드 파일 단위 정보 VO (이름, 경로, 크기, Content-Type 등) |
| StructFile      | 업로드 파일의 경로/이름/필드명 구조화 DTO |

#### 파일 업로드 처리 흐름

- 멀티파트 요청 파싱 → 파일 저장 → FileInfo/JUploadedFile 등 객체로 메타데이터 관리
- 파라미터와 파일 필드 구분, 인코딩/크기 제한/경로 검증 등 실무적 요구 반영

```java
// JFileUpload 파일 업로드 및 저장 예시
public FileInfo[] upload(String fileCategory) throws JServletException {
    // ... 업로드 경로/정책 결정
    return save(fileDir.toString(), PHYSICAL, fileCategory, relativePath);
}
```

#### 파일 다운로드 처리 흐름

- 세션/인증 체크 → 파일 경로/파라미터 검증 → Content-Type/Disposition 등 헤더 설정 → 파일 스트림 전송

```java
// JFileDownload 파일 다운로드 예시
public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // ... 세션/인증/경로/브라우저 처리
    bout = new BufferedOutputStream(response.getOutputStream(), 4096);
    bin = new BufferedInputStream(new FileInputStream(filepath), 4096);
    // ... 파일 스트림 전송
}
```

---

### 1.4. 예외 및 메시지 처리

#### 주요 클래스 및 역할

| 클래스명            | 주요 역할 및 설명 |
|---------------------|------------------|
| JServletException   | 서블릿 계층 예외, 코드/메시지/Msg 객체 등 구조화 |
| JException          | 시스템 공통 예외, 래핑/코드/메시지/원인 예외 관리 |
| JMailException      | 메일 처리 예외 |
| Msg                 | 메시지 객체 (코드, 다국어, 상세 설명 등) |

#### 예외 처리 구조

- 예외 상황에 따라 코드/메시지/Msg 객체 등 다양한 정보 전달
- 부모 예외(JException)와의 연계로 예외 정보 계층적 전달

```java
// JServletException 예시
public JServletException(int code, String exMsg, Msg msg) {
    super(code, exMsg, msg);
}
```

---

## 2. 비즈니스/데이터/도메인/설정/유틸리티 계층

### 2.1. 코드/화면/페이징 관리

#### 주요 클래스 및 역할

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| CodeManager     | 코드 테이블 중앙 관리, 코드명/표시명/관계코드/다국어/콤보박스 생성 등 |
| ScreenManager   | 화면 정의(XML) 중앙 관리, 동적 로딩/캐싱, 다국어 지원 |
| Screen          | 화면 단위 데이터 컨테이너(블록/타입) |
| PagedList       | 페이징 데이터 컨테이너, 페이징 UI 생성 지원 |

#### 코드/화면/페이징 처리 흐름

- 코드 테이블을 메모리에 적재, 코드명/표시명/관계코드 등 빠른 조회 및 UI 생성
- 화면 정의(XML) 동적 로딩 및 캐싱, 다국어/다채널 지원
- 대량 데이터의 페이지 단위 관리 및 페이징 UI(네비게이션) 생성

```java
// CodeManager 코드명 조회 예시
public String getCodeName(String code) {
    Object obj = getObject(code);
    if(obj == null) return "";
    String[] data = (String[])obj;
    return data[NAME];
}
```

---

### 2.2. 환경설정/상수/프로퍼티 관리

#### 주요 클래스 및 역할

| 클래스명                | 주요 역할 및 설명 |
|-------------------------|------------------|
| Configuration           | 환경설정(프로퍼티) 중앙 관리, 타입별 조회/예외처리/동적 리프레시 |
| Const                   | 시스템 전역 상수 집합 (DBMS, 인코딩, 언어, 환경설정 키 등) |
| JProperties             | 프로퍼티 확장, 타입 안전 조회/저장/예외처리/객체 저장 등 |
| ConfigurationException  | 설정 계층 예외 |
| JPropertiesException    | 프로퍼티 계층 예외 |

#### 환경설정 관리 흐름

- 설정 파일 로딩/초기화 → 타입별 안전 조회 → 예외/기본값 처리 → 동적 리프레시 지원

```java
// Configuration 설정값 조회 예시
public static String getString(String name, String defaultStr) {
    refresh();
    String ret = "";
    try {
        ret = prop.getString(name);
    } catch(JPropertiesException ex) {
        ret = defaultStr;
    }
    return ret;
}
```

---

### 2.3. 공통 유틸리티/보안/암호화

#### 주요 클래스 및 역할

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| Util            | 범용 유틸리티(데이터 변환, 입력값 검증, 보안, 환경, DB 등) |
| ICBSUtil        | 업무 특화 유틸리티(날짜/문자열/한글/보안 등) |
| SQLUtil         | SQL 동적 생성, 파라미터 바인딩, 검색 조건 파싱/검증 등 |
| JspUtil         | JSP/Servlet UI 유틸리티(인코딩, 콤보박스, 페이징 등) |
| Base64Util      | Base64 인코딩/디코딩/Reverse 등 |
| AES256Util/AES256Util2 | AES256 암호화/복호화, 환경설정 기반 키/IV 관리 |
| ICBSEncoder     | 커스텀 인코딩/디코딩, 중복 인코딩 관리 등 |

#### 주요 기능

- 데이터 변환, 입력값 검증, 보안(XSS/SQL Injection/OS Command Injection/HTTP Response Splitting 등)
- 암호화/복호화, 인코딩/디코딩, 공통 UI 생성, SQL 동적 생성 등

```java
// Util XSS 필터 예시
public static String filter(String oldStr) {
    if (oldStr == null) return null;
    StringBuffer result = new StringBuffer(oldStr.length());
    for (int i=0; i<oldStr.length(); ++i) {
        switch (oldStr.charAt(i)) {
            case \'<\': result.append("&lt;"); break;
            // ... 생략
            default: result.append(oldStr.charAt(i)); break;
        }
    }
    return result.toString();
}
```

---

### 2.4. 메시지/로깅/예외/파일/세션/메일/JMS

#### 주요 클래스 및 역할

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| Msg             | 메시지 객체(코드, 다국어, 상세 설명 등) |
| Log             | 시스템 로깅 유틸리티 |
| FileLogger/FileLoggerIF | 파일 기반 로깅, 로그 타입/파일명/경로 상수 등 |
| JMail           | 메일 송수신, 첨부파일/인코딩 등 지원 |
| JMSMsgSender/Receiver | JMS 메시지 송수신, 큐/세션/예외/로깅 등 관리 |

---

## 3. 데이터/도메인 계층

### 3.1. 데이터 객체 및 구조체

#### 주요 클래스 및 역할

| 클래스명        | 주요 역할 및 설명 |
|-----------------|------------------|
| FileInfo        | 파일 메타데이터 DTO (ID, 이름, 경로, 크기, 확장자 등) |
| JUploadedFile   | 업로드 파일 단위 정보 VO (이름, 경로, 크기, Content-Type 등) |
| StructFile      | 업로드 파일의 경로/이름/필드명 구조화 DTO |
| ComENT          | 대량 파라미터 집합 관리 VO/DTO |
| Screen          | 화면 단위 데이터 컨테이너(블록/타입) |
| ICBSStructSession | 세션 구조체, 사용자 인증/상태/OTP 등 관리 |
| PagedList       | 페이징 데이터 컨테이너, 페이징 UI 생성 지원 |

---

## 4. 시퀀스 다이어그램 예시

아래는 "파일 업로드 요청"의 전체 처리 흐름을 시퀀스 다이어그램으로 나타낸 예시입니다.

```mermaid
sequenceDiagram
    participant Client as 웹 브라우저
    participant Controller as JFileUpload
    participant Request as JRequest
    participant FileInfo as FileInfo
    participant Util as Util
    participant Config as Configuration

    Client->>+Controller: multipart/form-data 파일 업로드 요청
    Controller->>+Request: 파라미터/파일 추출
    Request-->>-Controller: 파라미터/파일 데이터
    Controller->>+Config: 업로드 경로/정책 조회
    Config-->>-Controller: 업로드 경로/정책
    Controller->>+Util: 인코딩/파일명 변환 등
    Util-->>-Controller: 변환 결과
    Controller->>+FileInfo: 파일 메타데이터 생성
    FileInfo-->>-Controller: FileInfo[]
    Controller-->>-Client: 업로드 결과 응답
    deactivate Controller
```
**설명:**
- Controller(JFileUpload)가 요청을 받아 파라미터/파일 추출, 환경설정 조회, 인코딩/파일명 변환, 파일 메타데이터 생성 등 각 계층과 협력하여 파일 업로드를 처리합니다.

---

## 5. 데이터 모델/구성 요약

### FileInfo 주요 필드

| 필드명           | 타입     | 설명                      |
|------------------|----------|---------------------------|
| fileId           | String   | 파일 ID (PK 조합)         |
| uniqueFileName   | String   | 고유 파일명(타임스탬프)   |
| fileCategory     | String   | 파일 분류                 |
| relativePath     | String   | 상대 경로                 |
| fileName         | String   | 원본 파일명               |
| fileExt          | String   | 파일 확장자               |
| fileSize         | String   | 파일 크기                 |
| useyn            | String   | 사용 여부                 |
| regdt            | Date     | 등록일                    |
| upddt            | Date     | 수정일                    |
| oldUniqueFileName| String   | 이전 파일명               |
| absolutePath     | String   | 전체 경로                 |

---

## 6. API/파라미터/설정 요약

### JFileUpload 주요 메서드

| 메서드명            | 파라미터/타입           | 설명                                 |
|---------------------|-------------------------|--------------------------------------|
| upload              | fileCategory, structFile| 파일 업로드 및 저장                  |
| saveAs              | uploadDir, timeStamp    | 지정 경로에 파일 저장                |
| getFileCount        | 없음                    | 업로드된 파일 개수 반환              |
| getFile             | name or index           | 업로드 파일 객체 반환                |
| getParameter        | name                    | 폼 파라미터 값 반환                  |
| setMaxFileSize      | maxFileSize             | 파일 크기 제한 설정                  |

---

## 7. 결론

**서블릿 및 필터 처리 모듈**은
- 웹 요청/응답의 표준화,
- 파라미터 인코딩/검증/자동 매핑,
- 세션/파일/예외/로깅/보안/암호화 등
실무적 요구를 일관성 있게 지원하는 **웹 애플리케이션의 핵심 인프라 계층**입니다.

이 모듈은
- 각 계층별 책임 분리와 협력,
- 환경설정 기반 유연성,
- 데이터/도메인/유틸리티/예외/로깅 등 공통 모듈과의 연동,
- 확장성과 유지보수성을 고려한 설계로
시스템 전체의 품질과 신뢰성을 보장합니다.

**향후 발전 방향**으로는
- 타입 안전성/제네릭/불변성 강화,
- 보안/입력 검증 고도화,
- 테스트 용이성/DI/Mock 지원,
- 최신 Java/웹 표준 반영,
- 설정/정책의 외부화 및 국제화 등
지속적 개선이 필요합니다.

**이 문서는 각 소스 파일의 상세 분석 결과를 바탕으로,
실제 구현 구조와 흐름을 정확하게 반영하였으며,
실무 개발자들이 시스템 구조와 역할을 빠르게 이해하고
유지보수/확장에 활용할 수 있도록 작성되었습니다.**', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('2784b8eb-2abc-4e36-a12f-556c4221b56c', e'# 로그 및 UI 관리

## 소개

**로그 및 UI 관리**는 시스템의 동작, 오류, 상태, 사용자 행위 등 다양한 이벤트를 일관성 있게 기록하고, 사용자 인터페이스(UI)에서 이를 효과적으로 시각화·제어하기 위한 핵심 인프라입니다.
본 문서는 제공된 소스 코드에 기반하여, 로그 기록(LogWriter, Log), 메시지 이벤트 처리(JMSMsgSender/Receiver, Msg, MsgManager), 환경설정(Configuration), 예외 처리, 공통 유틸리티, DB 연동, 그리고 스윙 기반 UI 관리의 전체 구조와 흐름을 체계적으로 설명합니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 주요 레이어와 컴포넌트 간의 의존성 및 호출 흐름을 시각적으로 보여줍니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        A["Controller/JSP/Servlet"]
        UIApplication
        MDIApplication
        SDIApplication
        SwingApplication
        StatusBar
        SplashScreen
        Window
        ToolbarButton
        FSBrowserRenderer
        BaseTableModel
        GridLayout2
        AbsoluteLayout
        AbsoluteConstraints
        ScrollableDesktopPane
        DesktopScrollPane
        BaseDesktopPane
    end
    subgraph "Business Layer"
        B["Service/Business Logic"]
        WindowManager
        CodeManager
        ScreenManager
    end
    subgraph "Logging & Messaging Layer"
        C["Log"]
        D["LogWriter"]
        E["Msg"]
        F["MsgManager"]
        G["JMSMsgSender"]
        H["JMSMsgReceiver"]
    end
    subgraph "Data Access Layer"
        I["DBConnPool"]
        J["JConnection"]
        K["JPreparedStatement"]
        L["DBObject_ORA/MSSQL"]
        JProperties
        JPropertiesException
        BaseFileFilter
        PagedList
    end
    subgraph "Domain Layer"
        ResourceManager
        ResourceConst
        PropertyConst
        Const
    end
    subgraph "Event Layer"
        JEventManager
        JEventListener
        ApplicationListener
        ApplicationAdapter
        JEvent
        ApplicationEvent
    end
    subgraph "Configuration Layer"
        M["Configuration"]
        N["JProperties"]
        O["Const"]
        Util
    end
    subgraph "Common Utility Layer"
        P["Util"]
        Q["JException/MsgException"]
    end

    A --> B
    B --> C
    B --> E
    B --> G
    B --> I
    C --> D
    D --> M
    D --> O
    D --> Q
    E --> F
    F --> M
    G --> H
    G --> F
    G --> M
    H --> F
    H --> M
    I --> J
    J --> K
    K --> L
    L --> M
    M --> N
    M --> O
    B --> P
    D --> Q
    F --> Q
    K --> Q
    P --> Q

    UIApplication -->|상속| MDIApplication
    UIApplication -->|상속| SDIApplication
    UIApplication -->|리소스| ResourceManager
    UIApplication -->|이벤트| JEventManager
    UIApplication -->|상태바| StatusBar
    UIApplication -->|스플래시| SplashScreen
    UIApplication -->|메뉴/툴바| ResourceManager

    MDIApplication -->|윈도우관리| WindowManager
    MDIApplication -->|데스크톱| ScrollableDesktopPane
    MDIApplication -->|데스크톱| BaseDesktopPane
    MDIApplication -->|상속| UIApplication

    SwingApplication -->|UI생성| StatusBar
    SwingApplication -->|UI생성| ToolbarButton
    SwingApplication -->|UI생성| SplashScreen

    WindowManager -->|창관리| Window
    Window -->|내부프레임| BaseDesktopPane

    StatusBar -->|상태변경| PropertyConst
    ToolbarButton -->|상태바연동| StatusBar

    FSBrowserRenderer -->|아이콘생성| SwingApplication

    ResourceManager -->|설정| ResourceConst
    ResourceManager -->|설정| PropertyConst
    ResourceManager -->|설정| Const

    JEventManager -->|리스너| JEventListener
    JEventManager -->|이벤트| JEvent
    JEventManager -->|이벤트| ApplicationEvent
    JEventManager -->|리스너| ApplicationListener
    JEventManager -->|리스너| ApplicationAdapter

    CodeManager -->|설정| Const
    ScreenManager -->|설정| Const

    Util -->|공통유틸| 모든노드

    BaseTableModel -->|테이블| Presentation Layer
    GridLayout2 -->|레이아웃| Presentation Layer
    AbsoluteLayout -->|레이아웃| Presentation Layer
    AbsoluteConstraints -->|레이아웃| AbsoluteLayout

    DesktopScrollPane -->|데스크톱| BaseDesktopPane
    ScrollableDesktopPane -->|데스크톱| DesktopScrollPane

    JProperties -->|설정| ResourceManager
    JPropertiesException -->|예외| JProperties
    BaseFileFilter -->|파일필터| FSBrowserRenderer
    PagedList -->|페이징| BaseTableModel

    ResourceConst -->|상수| ResourceManager
    PropertyConst -->|상수| StatusBar
    Const -->|상수| CodeManager
```
*위 다이어그램은 각 레이어별 주요 컴포넌트와 호출/의존 흐름을 나타냅니다.*

---

## 1. 로그 기록 및 메시지 이벤트 관리

### 1.1 로그 기록(LogWriter/Log)

- **LogWriter**: 로그 레벨(DBG, INFO, ERR 등)별로 로그 메시지를 콘솔/파일에 기록하는 유틸리티 클래스입니다. 환경설정(Configuration) 기반 정책, 파일 롤링, 동기화, 메시지 포맷, 예외 로깅을 지원합니다.
- **Log**: LogWriter 인스턴스를 전역적으로 제공하며, Log.info, Log.err 등으로 손쉽게 로그 기록이 가능합니다.

| 클래스/필드/메서드         | 설명                                                         |
|---------------------------|--------------------------------------------------------------|
| LogWriter                 | 로그 기록의 모든 세부 정책(레벨, 채널, 포맷, 동기화 등) 관리 |
| LogWriter.println()       | 다양한 타입/예외의 로그 메시지 기록                          |
| LogWriter.checkPrintWriter() | 날짜별 파일 롤링 및 PrintWriter 관리                       |
| LogWriter.getHeader()     | 로그 메시지 헤더(타임스탬프, 레벨, 호출 위치 등) 생성         |
| Log                       | 로그 레벨별 LogWriter 인스턴스 전역 제공                    |

#### 로그 기록 흐름 시퀀스

```mermaid
sequenceDiagram
    participant Controller
    participant Log
    participant LogWriter
    participant Configuration
    participant FileSystem

    Controller->>Log: Log.info.println("message")
    Log->>LogWriter: println("message")
    LogWriter->>Configuration: getBoolean(log_env)
    LogWriter->>LogWriter: checkPrintWriter()
    LogWriter->>FileSystem: (필요시) createPrintWriter()
    LogWriter->>LogWriter: getHeader()
    LogWriter->>FileSystem: write log line
```

#### 로그 레벨/정책/포맷 요약

| 로그 레벨 | 콘솔 출력 | 파일 출력 | 환경설정 키                | 헤더 포맷 예시                                 |
|-----------|-----------|-----------|---------------------------|------------------------------------------------|
| DBG       | O/X       | O/X       | log.dbg, log.dbg.console  | [2024-06-13 10:00:00 - DBG - MyClass.method()] |
| INFO      | O/X       | O/X       | log.info, log.info.console| [2024-06-13 10:00:00 - INFO - ...]             |
| ERR       | O/X       | O/X       | log.err, log.err.console  | [2024-06-13 10:00:00 - ERR - ...]              |
| SEVERE    | O/X       | O/X       | log.severe, log.severe.console| ...                                       |
| SYS       | O/X       | O/X       | log.sys, log.sys.console  | ...                                            |

---

### 1.2 메시지 이벤트 관리(Msg, JMSMsgSender/Receiver, MsgManager)

- **Msg**: 메시지 타입(type)과 내용(message)을 구조화하여 전달하는 표준 메시지 객체입니다.
- **MsgManager**: 메시지 코드별로 다국어 메시지/타입을 DB에서 읽어와 메모리에 캐싱, 코드로 메시지/타입을 빠르게 조회합니다.
- **JMSMsgSender/JMSMsgReceiver**: JMS 큐를 통한 메시지 송수신, 큐 리소스 관리, 예외 처리, 메시지 객체 직렬화/역직렬화 담당

| 클래스/필드/메서드         | 설명                                                         |
|---------------------------|--------------------------------------------------------------|
| Msg                       | 메시지 타입/내용을 가진 직렬화 가능한 VO/DTO                 |
| MsgManager                | 메시지 코드별 메시지/타입/다국어 관리, 싱글턴                |
| MsgManager.getMessage()   | 코드/언어별 메시지 반환                                      |
| JMSMsgSender.sendMessage()| JMS 큐로 메시지 송신                                         |
| JMSMsgReceiver.receiveMessage() | JMS 큐에서 메시지 수신                                |

#### 메시지 송수신 시퀀스

```mermaid
sequenceDiagram
    participant Service
    participant JMSMsgSender
    participant JMSMsgQueue
    participant JMSQueue
    participant JMSMsgReceiver

    Service->>JMSMsgSender: sendMessage(Msg)
    JMSMsgSender->>JMSMsgQueue: getQueueConnectionFactory()/getQueue()
    JMSMsgSender->>JMSQueue: send(ObjectMessage)
    JMSMsgSender->>JMSQueue: send(control message)
    Service->>JMSMsgReceiver: receiveMessage()
    JMSMsgReceiver->>JMSMsgQueue: getQueueConnectionFactory()/getQueue()
    JMSMsgReceiver->>JMSQueue: receive()
    JMSMsgReceiver-->>Service: Message
```

---

## 2. 환경설정 및 코드/화면/페이징 관리

### 2.1 환경설정(Configuration/JProperties/Const)

- **Configuration**: 시스템 환경설정 파일을 로딩, 타입별(getString/getInt/getBoolean)로 안전하게 값 반환, 동적 리프레시 지원
- **JProperties**: Properties 확장, 타입 안전 변환, 예외 처리, 객체 저장/조회 지원
- **Const**: 시스템 전역 상수(환경설정 키, 코드값, 언어, 인코딩 등) 정의

| 필드/메서드                  | 설명                                         |
|------------------------------|----------------------------------------------|
| Configuration.getString()    | 문자열 설정값 반환                           |
| Configuration.getInt()       | 정수형 설정값 반환                           |
| Configuration.getBoolean()   | 불리언 설정값 반환                           |
| JProperties.getObject()      | 임의 객체 저장/조회                          |
| Const.PROP_LOG_DBG           | 로그 환경설정 키 예시                        |

---

### 2.2 코드/화면/페이징 관리

- **CodeManager**: 코드 테이블을 메모리에 적재, 코드값/코드명/다국어/관계코드 등 조회 및 콤보박스 UI 동적 생성 지원
- **ScreenManager/Screen**: 화면 정의 XML을 로딩, 화면별 블록/타입 정보를 중앙 관리, 동적 화면 구성 지원
- **PagedList/JspUtil**: 페이징 데이터 컨테이너 및 페이징 UI(HTML) 동적 생성 지원

---

## 3. 예외 및 공통 유틸리티

### 3.1 예외 처리

- **JException/MsgException/ConfigurationException/JPropertiesException/UtilException**:
  도메인별 예외를 구조화, 메시지 객체/코드/원인 예외 등 다양한 정보를 래핑하여 일관된 예외 처리 제공

```mermaid
classDiagram
    class Exception
    class JException
    class MsgException
    class ConfigurationException
    class JPropertiesException
    class UtilException

    Exception <|-- JException
    JException <|-- MsgException
    JException <|-- ConfigurationException
    JException <|-- JPropertiesException
    RuntimeException <|-- UtilException
```

---

### 3.2 공통 유틸리티

- **Util**: 데이터 변환, 날짜/시간, 문자열 치환, 입력값 검증(XSS/SQL/OS Command/HTTP Response Splitting 등), 환경설정 로딩, DB 권한 체크 등 범용 기능 제공
- **SQLUtil**: SQL 검색 조건 파싱/인코딩/디코딩, 동적 SQL 생성, PreparedStatement 파라미터 바인딩 등 SQL 관련 유틸리티
- **JspUtil**: URL 인코딩/디코딩, HTML 안전 변환, 콤보박스/페이징 UI 동적 생성 등 웹 프레젠테이션 유틸리티

---

## 4. DB 연동 및 커넥션 풀 관리

- **DBConnPool/DBConnPool_WL**: 멀티 데이터소스 커넥션 풀 관리, 커넥션 획득/반납, 예외 처리, 자원 관리
- **JConnection/JPreparedStatement/JStatement/JResultSet**: JDBC 표준 객체 래핑, 파라미터 관리, 예외 추상화, 로깅, 성능 모니터링 등 실무적 요구 반영
- **DBObject_ORA/DBObject_MSSQL**: DBMS별(Oracle/MSSQL) 특화 기능(주석 조회, ID 생성 등) 캡슐화

---

## 5. 스윙 기반 UI 관리

### 5.1 리소스 및 설정 관리

- **ResourceManager**: UI 리소스(문자열, 폰트, 색상, 아이콘 등) 및 접근성 관리의 중앙 허브. 외부 설정(properties) 기반의 리소스 로딩, 메뉴/툴바/상태바/스플래시 등 UI 컴포넌트 동적 생성, 권한/접근성 그룹별 UI 제어, 싱글턴 패턴 적용.
- **ResourceConst, PropertyConst, Const**: UI 리소스/설정/이벤트/언어/환경설정 등에서 사용하는 문자열 상수 집합.

| 상수명 | 설명 |
|--------|------|
| MENU_ITEMS | 메뉴 항목 키 |
| STATUSBAR_FONT_NAME | 상태바 폰트명 |
| MSG_APP_INIT | 애플리케이션 초기화 메시지 키 |

---

### 5.2 UI 프레임워크 및 컴포넌트

- **UIApplication, MDIApplication, SDIApplication**: UI 라이프사이클(초기화, 종료, 리소스 로딩, 이벤트 처리 등) 관리의 추상 기반 클래스 및 MDI/SDI 환경 지원.
- **SwingApplication**: Swing 컴포넌트 생성, 다이얼로그, 스타일, 레이아웃, 이벤트 처리 등 UI 개발의 표준 템플릿/유틸리티 제공.
- **StatusBar, SplashScreen, ToolbarButton**: 상태 메시지/진행바 표시, 스플래시, 툴바 버튼 커스터마이즈 및 상태바 연동.

---

### 5.3 MDI/데스크톱/윈도우 관리

- **WindowManager, Window**: 창(Window, JInternalFrame 등) 생성/등록/배치/상태관리/메뉴 동기화의 중앙 컨트롤러 및 내부 프레임 표준화.
- **ScrollableDesktopPane, DesktopScrollPane, BaseDesktopPane, BaseDesktopManager**: 스크롤 가능한 데스크톱 영역, 내부 프레임 상태 관리, 데스크톱 패널 연동.

---

### 5.4 테이블/레이아웃/그래프/파일 브라우저

- **BaseTableModel**: Swing TableModel 표준 구현, 컬럼명/데이터/편집 가능성 관리, 데이터 변경 시 UI 동기화.
- **GridLayout2, AbsoluteLayout, AbsoluteConstraints**: 유연한 그리드/절대 좌표 레이아웃 매니저 및 제약조건 객체.
- **FSBrowserRenderer**: 파일 시스템 브라우저 트리에서 파일/폴더/루트 노드별로 아이콘을 동적으로 지정하는 커스텀 렌더러.

---

### 5.5 이벤트 및 라이프사이클 관리

- **JEventManager, JEventListener, ApplicationListener, ApplicationAdapter, JEvent, ApplicationEvent**: 이벤트 허브, 리스너 등록/해제/분배, 애플리케이션 라이프사이클 이벤트 관리.

```mermaid
sequenceDiagram
    participant UIApplication as UIApplication
    participant JEventManager as JEventManager
    participant ApplicationListener as ApplicationListener

    UIApplication->>JEventManager: fireEvent(ApplicationListener, ApplicationEvent, "applicationInit")
    activate JEventManager
    JEventManager->>ApplicationListener: applicationInit(ApplicationEvent)
    deactivate JEventManager
```

---

## 6. 데이터 흐름 및 호출 관계 요약

```mermaid
flowchart TD
    Controller["Controller/Service"]
    Log["Log/LogWriter"]
    MsgSender["JMSMsgSender"]
    MsgReceiver["JMSMsgReceiver"]
    MsgManager["MsgManager"]
    Configuration["Configuration"]
    DB["DBConnPool/JConnection"]
    Util["Util"]
    UIApplication
    ResourceManager
    WindowManager
    StatusBar

    Controller --> Log
    Controller --> MsgSender
    Controller --> MsgManager
    Controller --> Configuration
    Controller --> DB
    Controller --> Util
    MsgSender --> MsgManager
    MsgSender --> Configuration
    MsgReceiver --> MsgManager
    MsgReceiver --> Configuration
    Log --> Configuration
    Log --> Util
    MsgManager --> Configuration
    MsgManager --> DB
    DB --> Configuration
    Util --> Configuration

    UIApplication --> ResourceManager
    UIApplication --> WindowManager
    UIApplication --> StatusBar
    ResourceManager --> Configuration
    WindowManager --> UIApplication
    StatusBar --> ResourceManager
```

---

## 7. 데이터/구성 요약 테이블

### 7.1 로그 레벨/정책/포맷

| 로그 레벨 | 콘솔 출력 | 파일 출력 | 환경설정 키                | 헤더 포맷 예시                                 |
|-----------|-----------|-----------|---------------------------|------------------------------------------------|
| DBG       | O/X       | O/X       | log.dbg, log.dbg.console  | [2024-06-13 10:00:00 - DBG - MyClass.method()] |
| INFO      | O/X       | O/X       | log.info, log.info.console| [2024-06-13 10:00:00 - INFO - ...]             |
| ERR       | O/X       | O/X       | log.err, log.err.console  | [2024-06-13 10:00:00 - ERR - ...]              |
| SEVERE    | O/X       | O/X       | log.severe, log.severe.console| ...                                       |
| SYS       | O/X       | O/X       | log.sys, log.sys.console  | ...                                            |

### 7.2 메시지 객체 구조

| 필드명   | 타입    | 설명                      |
|----------|---------|--------------------------|
| type     | String  | 메시지 유형(ERR/INFO 등)  |
| message  | String  | 메시지 내용               |

### 7.3 환경설정 주요 키

| 키명                  | 타입    | 기본값/예시           | 설명                       |
|-----------------------|---------|-----------------------|----------------------------|
| log.dir               | String  | logs/                 | 로그 파일 디렉토리         |
| log.dbg               | boolean | true/false            | DBG 로그 파일 출력 여부    |
| log.dbg.console       | boolean | true/false            | DBG 로그 콘솔 출력 여부    |
| log.info              | boolean | true/false            | INFO 로그 파일 출력 여부   |
| log.info.console      | boolean | true/false            | INFO 로그 콘솔 출력 여부   |
| msg.lang              | String  | KO/EN                 | 메시지 기본 언어           |
| db.pool_name          | String  | pool1;pool2           | DB 커넥션 풀 이름 목록     |

### 7.4 UI 리소스/설정 주요 상수

| 상수명 | 타입 | 설명 |
|--------|------|------|
| MENU_ITEMS | String | 메뉴 항목 키 |
| TOOLBAR_ITEMS | String | 툴바 항목 키 |
| STATUSBAR_FONT_NAME | String | 상태바 폰트명 |
| SPLASH_IMAGE | String | 스플래시 이미지 경로 |
| MSG_APP_INIT | String | 애플리케이션 초기화 메시지 키 |

---

## 8. 코드 스니펫 예시

### 8.1 로그 기록 예시

```java
// 로그 기록 (INFO)
Log.info.println("시스템이 시작되었습니다.");

// 로그 기록 (ERR, 예외 포함)
try {
    // ... some code
} catch(Exception ex) {
    Log.err.println(ex, "DB 연결 실패");
}
```

### 8.2 메시지 조회 및 송신 예시

```java
// 메시지 코드로 메시지 조회
String msg = MsgManager.getInstance().getMessage("ERR001");

// 메시지 객체 생성 및 JMS 송신
Msg msgObj = new Msg(Msg.ERR, "처리 중 오류가 발생했습니다.");
JMSMsgSender sender = new JMSMsgSender();
sender.sendMessage(msgObj);
```

### 8.3 환경설정 값 조회 예시

```java
// 환경설정에서 로그 디렉토리 조회
String logDir = Configuration.getString(Const.PROP_LOG_DIR, "/default/logs");
```

### 8.4 DB 커넥션 획득 및 쿼리 실행 예시

```java
// DB 커넥션 획득
JConnection conn = DBConnPool_WL.getConnection();
JPreparedStatement pstmt = conn.prepareStatement("SELECT * FROM user WHERE id = ?");
pstmt.setInt(1, userId);
JResultSet rs = pstmt.executeQuery();
```

### 8.5 UI 리소스 및 컴포넌트 생성 예시

```java
// 메뉴바/툴바/상태바 동적 생성
JMenuBar menuBar = ResourceManager.getInstance().loadMenuBar();
JToolBar[] toolBars = ResourceManager.getInstance().loadToolBars();
StatusBar statusBar = ResourceManager.getInstance().createStatusBar();
```

---

## 결론

본 문서에서는 제공된 소스 코드 기반으로 **로그 및 UI 관리**의 전체 구조, 아키텍처, 데이터 흐름, 주요 컴포넌트, 설정, 예외, 유틸리티, DB 연동, 스윙 기반 UI 관리까지 실무적 요구를 충실히 반영한 시스템 설계를 체계적으로 정리하였습니다.

- **로그 기록(LogWriter/Log)**: 환경설정 기반의 유연한 정책, 멀티스레드 안전성, 일관된 메시지 포맷, 다양한 데이터/예외 지원, 파일 롤링 등 실무적 요구를 폭넓게 반영
- **메시지 이벤트(Msg, JMSMsgSender/Receiver, MsgManager)**: 메시지의 구조화, 다국어/타입 관리, JMS 기반 송수신, 예외 처리, 리소스 관리 등 메시지 기반 아키텍처의 표준화
- **환경설정/코드/화면/페이징/유틸리티/DB 연동**: 시스템 전반의 설정, 코드/메시지/화면/페이징/유틸리티/DB 커넥션 풀 관리까지 중앙 집중적이고 일관된 관리 구조
- **스윙 기반 UI 관리**: 리소스/설정/접근성/컴포넌트 생성/이벤트/테이블/그래프/파일 브라우저/보안/환경 관리 등 데스크톱 UI의 표준화와 확장성 보장

이러한 구조는 **대규모 엔터프라이즈 시스템에서의 신뢰성, 유지보수성, 확장성, 실무적 요구 대응력**을 모두 만족시키는 설계임을 알 수 있습니다.
**로그 및 UI 관리**는 시스템의 "운영 품질, 장애 분석, 사용자 경험, 보안, 확장성"을 책임지는 핵심 인프라 계층입니다.
각 컴포넌트의 역할과 상호작용을 정확히 이해하고, 환경설정/정책/확장성/테스트/운영 측면에서 지속적으로 개선해 나가는 것이 중요합니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('b7acadfd-c89f-43c4-84ff-1e77b4c7b29c', e'# 로그 및 메시지 이벤트 관리

## 소개

**로그 및 메시지 이벤트 관리**는 시스템 전반의 동작, 오류, 상태, 사용자 행위 등 다양한 이벤트를 일관된 방식으로 기록·전달·분석하기 위한 핵심 인프라입니다.
이 문서는 제공된 소스 코드에 기반하여, 로그 기록(LogWriter, Log), 메시지 이벤트 처리(JMSMsgSender/Receiver, Msg, MsgManager), 환경설정(Configuration), 예외 처리, 공통 유틸리티, DB 연동 등 시스템 내 로그 및 메시지 관리의 전체 구조와 흐름을 체계적으로 설명합니다.

아래 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 주요 레이어와 컴포넌트 간의 의존성 및 호출 흐름을 시각적으로 보여줍니다.

**아키텍처 다이어그램 설명:**
- Controller/Presentation 계층에서 발생하는 이벤트는 Business(Service) 계층을 거쳐, 로그 기록 및 메시지 송수신, DB 연동, 환경설정 등 다양한 인프라 계층과 상호작용합니다.
- 로그 기록은 LogWriter/Log를 통해, 메시지 이벤트는 JMSMsgSender/Receiver 및 MsgManager를 통해 처리됩니다.
- 모든 설정값, 코드/메시지, 예외, 유틸리티 기능은 Configuration, CodeManager, MsgManager, Util 등 공통 인프라 계층에서 중앙 집중적으로 관리됩니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        A["Controller/JSP/Servlet"]
    end
    subgraph "Business Layer"
        B["Service/Business Logic"]
    end
    subgraph "Logging & Messaging Layer"
        C["Log"]
        D["LogWriter"]
        E["Msg"]
        F["MsgManager"]
        G["JMSMsgSender"]
        H["JMSMsgReceiver"]
    end
    subgraph "Data Access Layer"
        I["DBConnPool"]
        J["JConnection"]
        K["JPreparedStatement"]
        L["DBObject_ORA/MSSQL"]
    end
    subgraph "Configuration Layer"
        M["Configuration"]
        N["JProperties"]
        O["Const"]
    end
    subgraph "Common Utility Layer"
        P["Util"]
        Q["JException/MsgException"]
    end

    A --> B
    B --> C
    B --> E
    B --> G
    B --> I
    C --> D
    D --> M
    D --> O
    D --> Q
    E --> F
    F --> M
    G --> H
    G --> F
    G --> M
    H --> F
    H --> M
    I --> J
    J --> K
    K --> L
    L --> M
    M --> N
    M --> O
    B --> P
    D --> Q
    F --> Q
    K --> Q
    P --> Q
```
*위 다이어그램은 각 레이어별 주요 컴포넌트와 호출/의존 흐름을 나타냅니다.*

---

## 1. 로그 기록 아키텍처

### 1.1 LogWriter/Log 구조

- **LogWriter**: 로그 레벨별(DBG, INFO, ERR, SEVERE, SYS)로 로그 메시지를 콘솔/파일에 기록하는 핵심 유틸리티 클래스입니다.
  - 환경설정(Configuration) 기반의 정책 적용, 파일 롤링, 동기화, 메시지 포맷, 예외 로깅 등 실무적 요구를 폭넓게 지원합니다.
- **Log**: LogWriter 인스턴스를 전역적으로 제공하는 유틸리티 클래스입니다.
  - Log.info, Log.err 등으로 손쉽게 로그 기록이 가능합니다.

#### 주요 클래스/메서드

| 클래스/필드/메서드         | 설명                                                         |
|---------------------------|--------------------------------------------------------------|
| LogWriter                 | 로그 기록의 모든 세부 정책(레벨, 채널, 포맷, 동기화 등) 관리 |
| LogWriter.println()       | 다양한 타입/예외의 로그 메시지 기록                          |
| LogWriter.checkPrintWriter() | 날짜별 파일 롤링 및 PrintWriter 관리                       |
| LogWriter.getHeader()     | 로그 메시지 헤더(타임스탬프, 레벨, 호출 위치 등) 생성         |
| Log                       | 로그 레벨별 LogWriter 인스턴스 전역 제공                    |

#### 로그 기록 흐름 시퀀스

```mermaid
sequenceDiagram
    participant Controller
    participant Log
    participant LogWriter
    participant Configuration
    participant FileSystem

    Controller->>Log: Log.info.println("message")
    Log->>LogWriter: println("message")
    LogWriter->>Configuration: getBoolean(log_env)
    LogWriter->>LogWriter: checkPrintWriter()
    LogWriter->>FileSystem: (필요시) createPrintWriter()
    LogWriter->>LogWriter: getHeader()
    LogWriter->>FileSystem: write log line
```
*로그 기록 시 Controller/Service에서 Log를 통해 LogWriter로 위임, 환경설정 및 파일 관리 후 로그 메시지 기록이 이루어집니다.*

---

### 1.2 로그 레벨/정책/포맷 요약

| 로그 레벨 | 콘솔 출력 | 파일 출력 | 환경설정 키                | 헤더 포맷 예시                                 |
|-----------|-----------|-----------|---------------------------|------------------------------------------------|
| DBG       | O/X       | O/X       | log.dbg, log.dbg.console  | [2024-06-13 10:00:00 - DBG - MyClass.method()] |
| INFO      | O/X       | O/X       | log.info, log.info.console| [2024-06-13 10:00:00 - INFO - ...]             |
| ERR       | O/X       | O/X       | log.err, log.err.console  | [2024-06-13 10:00:00 - ERR - ...]              |
| SEVERE    | O/X       | O/X       | log.severe, log.severe.console| ...                                       |
| SYS       | O/X       | O/X       | log.sys, log.sys.console  | ...                                            |

---

## 2. 메시지 이벤트 관리 아키텍처

### 2.1 메시지 객체 및 메시지 관리

- **Msg**: 메시지 타입(type)과 내용(message)을 구조화하여 전달하는 표준 메시지 객체입니다.
- **MsgManager**: 메시지 코드별로 다국어 메시지/타입을 DB에서 읽어와 메모리에 캐싱, 코드로 메시지/타입을 빠르게 조회합니다.

#### 주요 클래스/메서드

| 클래스/필드/메서드         | 설명                                                         |
|---------------------------|--------------------------------------------------------------|
| Msg                       | 메시지 타입/내용을 가진 직렬화 가능한 VO/DTO                 |
| MsgManager                | 메시지 코드별 메시지/타입/다국어 관리, 싱글턴                |
| MsgManager.getMessage()   | 코드/언어별 메시지 반환                                      |
| MsgManager.getType()      | 메시지 타입 반환                                             |

---

### 2.2 JMS 기반 메시지 송수신

- **JMSMsgSender**: JMS 큐로 메시지를 송신, 메시지 생성/예외 처리/리소스 관리 일괄 처리
- **JMSMsgReceiver**: JMS 큐에서 메시지를 수신, 연결/세션/수신기 생성 및 메시지 수신/예외 처리/자원 반환 일괄 처리
- **JMSMsgQueue**: JMS 큐 및 큐 팩토리의 JNDI lookup, 캐싱, 설정 기반 관리

#### 메시지 송수신 시퀀스

```mermaid
sequenceDiagram
    participant Service
    participant JMSMsgSender
    participant JMSMsgQueue
    participant JMSQueue
    participant JMSMsgReceiver

    Service->>JMSMsgSender: sendMessage(Msg)
    JMSMsgSender->>JMSMsgQueue: getQueueConnectionFactory()/getQueue()
    JMSMsgSender->>JMSQueue: send(ObjectMessage)
    JMSMsgSender->>JMSQueue: send(control message)
    Service->>JMSMsgReceiver: receiveMessage()
    JMSMsgReceiver->>JMSMsgQueue: getQueueConnectionFactory()/getQueue()
    JMSMsgReceiver->>JMSQueue: receive()
    JMSMsgReceiver-->>Service: Message
```
*서비스 계층에서 메시지 송신/수신 시, JMSMsgSender/Receiver가 JMSMsgQueue를 통해 큐 리소스를 획득, 메시지 송수신을 수행합니다.*

---

## 3. 환경설정 및 코드/화면 관리

### 3.1 환경설정(Configuration/JProperties/Const)

- **Configuration**: 시스템 환경설정 파일을 로딩, 타입별(getString/getInt/getBoolean)로 안전하게 값 반환, 동적 리프레시 지원
- **JProperties**: Properties 확장, 타입 안전 변환, 예외 처리, 객체 저장/조회 지원
- **Const**: 시스템 전역 상수(환경설정 키, 코드값, 언어, 인코딩 등) 정의

#### 환경설정 주요 필드/메서드

| 필드/메서드                  | 설명                                         |
|------------------------------|----------------------------------------------|
| Configuration.getString()    | 문자열 설정값 반환                           |
| Configuration.getInt()       | 정수형 설정값 반환                           |
| Configuration.getBoolean()   | 불리언 설정값 반환                           |
| JProperties.getObject()      | 임의 객체 저장/조회                          |
| Const.PROP_LOG_DBG           | 로그 환경설정 키 예시                        |

---

### 3.2 코드/화면/페이징 관리

- **CodeManager**: 코드 테이블을 메모리에 적재, 코드값/코드명/다국어/관계코드 등 조회 및 콤보박스 UI 동적 생성 지원
- **ScreenManager/Screen**: 화면 정의 XML을 로딩, 화면별 블록/타입 정보를 중앙 관리, 동적 화면 구성 지원
- **PagedList/JspUtil**: 페이징 데이터 컨테이너 및 페이징 UI(HTML) 동적 생성 지원

---

## 4. 예외 및 공통 유틸리티

### 4.1 예외 처리

- **JException/MsgException/ConfigurationException/JPropertiesException/UtilException**:
  도메인별 예외를 구조화, 메시지 객체/코드/원인 예외 등 다양한 정보를 래핑하여 일관된 예외 처리 제공

#### 예외 계층 구조

```mermaid
classDiagram
    class Exception
    class JException
    class MsgException
    class ConfigurationException
    class JPropertiesException
    class UtilException

    Exception <|-- JException
    JException <|-- MsgException
    JException <|-- ConfigurationException
    JException <|-- JPropertiesException
    RuntimeException <|-- UtilException
```
*JException을 중심으로 도메인별 예외가 계층적으로 설계되어 있습니다.*

---

### 4.2 공통 유틸리티

- **Util**: 데이터 변환, 날짜/시간, 문자열 치환, 입력값 검증(XSS/SQL/OS Command/HTTP Response Splitting 등), 환경설정 로딩, DB 권한 체크 등 범용 기능 제공
- **SQLUtil**: SQL 검색 조건 파싱/인코딩/디코딩, 동적 SQL 생성, PreparedStatement 파라미터 바인딩 등 SQL 관련 유틸리티
- **JspUtil**: URL 인코딩/디코딩, HTML 안전 변환, 콤보박스/페이징 UI 동적 생성 등 웹 프레젠테이션 유틸리티

---

## 5. DB 연동 및 커넥션 풀 관리

- **DBConnPool/DBConnPool_WL**: 멀티 데이터소스 커넥션 풀 관리, 커넥션 획득/반납, 예외 처리, 자원 관리
- **JConnection/JPreparedStatement/JStatement/JResultSet**: JDBC 표준 객체 래핑, 파라미터 관리, 예외 추상화, 로깅, 성능 모니터링 등 실무적 요구 반영
- **DBObject_ORA/DBObject_MSSQL**: DBMS별(Oracle/MSSQL) 특화 기능(주석 조회, ID 생성 등) 캡슐화

---

## 6. 데이터 흐름 및 호출 관계 요약

### 6.1 로그 및 메시지 이벤트 처리 플로우

```mermaid
flowchart TD
    Controller["Controller/Service"]
    Log["Log/LogWriter"]
    MsgSender["JMSMsgSender"]
    MsgReceiver["JMSMsgReceiver"]
    MsgManager["MsgManager"]
    Configuration["Configuration"]
    DB["DBConnPool/JConnection"]
    Util["Util"]

    Controller --> Log
    Controller --> MsgSender
    Controller --> MsgManager
    Controller --> Configuration
    Controller --> DB
    Controller --> Util
    MsgSender --> MsgManager
    MsgSender --> Configuration
    MsgReceiver --> MsgManager
    MsgReceiver --> Configuration
    Log --> Configuration
    Log --> Util
    MsgManager --> Configuration
    MsgManager --> DB
    DB --> Configuration
    Util --> Configuration
```
*컨트롤러/서비스 계층에서 로그 기록, 메시지 송수신, 메시지 조회, 환경설정, DB 연동, 유틸리티 기능을 필요에 따라 호출하며, 각 인프라 계층은 설정/DB/유틸리티와 상호작용합니다.*

---

## 7. 데이터/구성 요약 테이블

### 7.1 로그 레벨/정책/포맷

| 로그 레벨 | 콘솔 출력 | 파일 출력 | 환경설정 키                | 헤더 포맷 예시                                 |
|-----------|-----------|-----------|---------------------------|------------------------------------------------|
| DBG       | O/X       | O/X       | log.dbg, log.dbg.console  | [2024-06-13 10:00:00 - DBG - MyClass.method()] |
| INFO      | O/X       | O/X       | log.info, log.info.console| [2024-06-13 10:00:00 - INFO - ...]             |
| ERR       | O/X       | O/X       | log.err, log.err.console  | [2024-06-13 10:00:00 - ERR - ...]              |
| SEVERE    | O/X       | O/X       | log.severe, log.severe.console| ...                                       |
| SYS       | O/X       | O/X       | log.sys, log.sys.console  | ...                                            |

### 7.2 메시지 객체 구조

| 필드명   | 타입    | 설명                      |
|----------|---------|--------------------------|
| type     | String  | 메시지 유형(ERR/INFO 등)  |
| message  | String  | 메시지 내용               |

### 7.3 환경설정 주요 키

| 키명                  | 타입    | 기본값/예시           | 설명                       |
|-----------------------|---------|-----------------------|----------------------------|
| log.dir               | String  | logs/                 | 로그 파일 디렉토리         |
| log.dbg               | boolean | true/false            | DBG 로그 파일 출력 여부    |
| log.dbg.console       | boolean | true/false            | DBG 로그 콘솔 출력 여부    |
| log.info              | boolean | true/false            | INFO 로그 파일 출력 여부   |
| log.info.console      | boolean | true/false            | INFO 로그 콘솔 출력 여부   |
| msg.lang              | String  | KO/EN                 | 메시지 기본 언어           |
| db.pool_name          | String  | pool1;pool2           | DB 커넥션 풀 이름 목록     |

---

## 8. 코드 스니펫 예시

### 8.1 로그 기록 예시

```java
// 로그 기록 (INFO)
Log.info.println("시스템이 시작되었습니다.");

// 로그 기록 (ERR, 예외 포함)
try {
    // ... some code
} catch(Exception ex) {
    Log.err.println(ex, "DB 연결 실패");
}
```

### 8.2 메시지 조회 및 송신 예시

```java
// 메시지 코드로 메시지 조회
String msg = MsgManager.getInstance().getMessage("ERR001");

// 메시지 객체 생성 및 JMS 송신
Msg msgObj = new Msg(Msg.ERR, "처리 중 오류가 발생했습니다.");
JMSMsgSender sender = new JMSMsgSender();
sender.sendMessage(msgObj);
```

### 8.3 환경설정 값 조회 예시

```java
// 환경설정에서 로그 디렉토리 조회
String logDir = Configuration.getString(Const.PROP_LOG_DIR, "/default/logs");
```

### 8.4 DB 커넥션 획득 및 쿼리 실행 예시

```java
// DB 커넥션 획득
JConnection conn = DBConnPool_WL.getConnection();
JPreparedStatement pstmt = conn.prepareStatement("SELECT * FROM user WHERE id = ?");
pstmt.setInt(1, userId);
JResultSet rs = pstmt.executeQuery();
```

---

## 결론

본 문서에서는 제공된 소스 코드 기반으로 **로그 및 메시지 이벤트 관리**의 전체 구조, 아키텍처, 데이터 흐름, 주요 컴포넌트, 설정, 예외, 유틸리티, DB 연동까지 실무적 요구를 충실히 반영한 시스템 설계를 체계적으로 정리하였습니다.

- **로그 기록(LogWriter/Log)**: 환경설정 기반의 유연한 정책, 멀티스레드 안전성, 일관된 메시지 포맷, 다양한 데이터/예외 지원, 파일 롤링 등 실무적 요구를 폭넓게 반영
- **메시지 이벤트(Msg, JMSMsgSender/Receiver, MsgManager)**: 메시지의 구조화, 다국어/타입 관리, JMS 기반 송수신, 예외 처리, 리소스 관리 등 메시지 기반 아키텍처의 표준화
- **환경설정/코드/화면/페이징/유틸리티/DB 연동**: 시스템 전반의 설정, 코드/메시지/화면/페이징/유틸리티/DB 커넥션 풀 관리까지 중앙 집중적이고 일관된 관리 구조

이러한 구조는 **대규모 엔터프라이즈 시스템에서의 신뢰성, 유지보수성, 확장성, 실무적 요구 대응력**을 모두 만족시키는 설계임을 알 수 있습니다.

**로그 및 메시지 이벤트 관리**는 시스템의 "운영 품질, 장애 분석, 사용자 경험, 보안, 확장성"을 책임지는 핵심 인프라 계층입니다.
제공된 각 컴포넌트의 역할과 상호작용을 정확히 이해하고, 환경설정/정책/확장성/테스트/운영 측면에서 지속적으로 개선해 나가는 것이 중요합니다.', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('f791ef6c-1ea5-4502-948b-0aa387adb38c', e'# 스윙 기반 UI 및 그래프 기능

## 소개

본 문서는 com.pjedf.df.ui.swing 패키지를 중심으로 한 **스윙 기반 UI 및 그래프 기능**의 구조, 주요 컴포넌트, 데이터 흐름, 접근성 및 확장성에 대해 체계적으로 설명합니다.
이 시스템은 Java Swing을 기반으로, 데스크톱 애플리케이션의 UI 리소스 관리, 동적 메뉴/툴바/상태바 생성, MDI/SDI 프레임워크, 이벤트 처리, 테이블/그래프/파일 브라우저 등 다양한 UI 기능을 제공합니다.

### 전체 시스템 의존성 및 아키텍처 개요

아래 Mermaid.js 다이어그램은 전체 시스템의 주요 레이어와 클래스 간의 의존성 흐름을 시각적으로 나타냅니다.

**아키텍처 다이어그램**

```mermaid
graph TD
    subgraph "Presentation Layer"
        UIApplication
        MDIApplication
        SDIApplication
        SwingApplication
        StatusBar
        SplashScreen
        Window
        ToolbarButton
        FSBrowserRenderer
        BaseTableModel
        GridLayout2
        AbsoluteLayout
        AbsoluteConstraints
        ScrollableDesktopPane
        DesktopScrollPane
        BaseDesktopPane
    end

    subgraph "Business Layer"
        WindowManager
        CodeManager
        ScreenManager
    end

    subgraph "Data Layer"
        JProperties
        JPropertiesException
        BaseFileFilter
        PagedList
    end

    subgraph "Domain Layer"
        ResourceManager
        ResourceConst
        PropertyConst
        Const
    end

    subgraph "Event Layer"
        JEventManager
        JEventListener
        ApplicationListener
        ApplicationAdapter
        JEvent
        ApplicationEvent
    end

    subgraph "Configuration Layer"
        Util
    end

    %% 주요 흐름
    UIApplication -->|상속| MDIApplication
    UIApplication -->|상속| SDIApplication
    UIApplication -->|리소스| ResourceManager
    UIApplication -->|이벤트| JEventManager
    UIApplication -->|상태바| StatusBar
    UIApplication -->|스플래시| SplashScreen
    UIApplication -->|메뉴/툴바| ResourceManager

    MDIApplication -->|윈도우관리| WindowManager
    MDIApplication -->|데스크톱| ScrollableDesktopPane
    MDIApplication -->|데스크톱| BaseDesktopPane

    SwingApplication -->|UI생성| StatusBar
    SwingApplication -->|UI생성| ToolbarButton
    SwingApplication -->|UI생성| SplashScreen

    WindowManager -->|창관리| Window
    Window -->|내부프레임| BaseDesktopPane

    StatusBar -->|상태변경| PropertyConst
    ToolbarButton -->|상태바연동| StatusBar

    FSBrowserRenderer -->|아이콘생성| SwingApplication

    ResourceManager -->|설정| ResourceConst
    ResourceManager -->|설정| PropertyConst
    ResourceManager -->|설정| Const

    JEventManager -->|리스너| JEventListener
    JEventManager -->|이벤트| JEvent
    JEventManager -->|이벤트| ApplicationEvent
    JEventManager -->|리스너| ApplicationListener
    JEventManager -->|리스너| ApplicationAdapter

    CodeManager -->|설정| Const
    ScreenManager -->|설정| Const

    %% Util → 모든 주요 노드와 연결 (대표만 표시)
    Util --> UIApplication
    Util --> ResourceManager
    Util --> WindowManager
    Util --> JEventManager
    Util --> JProperties

    BaseTableModel -->|테이블| UIApplication
    GridLayout2 -->|레이아웃| UIApplication
    AbsoluteLayout -->|레이아웃| UIApplication
    AbsoluteConstraints -->|레이아웃| AbsoluteLayout

    DesktopScrollPane -->|데스크톱| BaseDesktopPane
    ScrollableDesktopPane -->|데스크톱| DesktopScrollPane

    %% 데이터/설정 흐름
    JProperties -->|설정| ResourceManager
    JPropertiesException -->|예외| JProperties
    BaseFileFilter -->|파일필터| FSBrowserRenderer
    PagedList -->|페이징| BaseTableModel

    %% 도메인/설정
    ResourceConst -->|상수| ResourceManager
    PropertyConst -->|상수| StatusBar
    Const -->|상수| CodeManager
```

**설명:**
- **Presentation Layer**: UI 프레임워크, 컴포넌트, 레이아웃, 상태바, 스플래시, 테이블, 그래프 등
- **Business Layer**: 창 관리, 코드 관리, 화면 관리 등 비즈니스 로직
- **Data Layer**: 설정, 파일 필터, 페이징 등 데이터/설정 관리
- **Domain Layer**: 리소스/프로퍼티/상수 등 도메인 모델
- **Event Layer**: 이벤트 매니저, 리스너, 이벤트 객체 등
- **Configuration Layer**: 범용 유틸리티, 환경설정 등

---

## 주요 컴포넌트 및 구조

### 1. 리소스 및 설정 관리

#### ResourceManager

- **역할**: UI 리소스(문자열, 폰트, 색상, 아이콘 등) 및 접근성 관리의 중앙 허브
- **주요 기능**:
    - 외부 설정(properties) 기반의 리소스 로딩 및 타입별 변환
    - 메뉴/툴바/상태바/스플래시 등 UI 컴포넌트 동적 생성
    - 권한/접근성 그룹별 UI 제어
    - 싱글턴 패턴으로 전역 일관성 보장

**주요 메서드 예시:**
```java
public String getString(String key)
public JMenuBar loadMenuBar() throws InvalidUIConfigurationException
public JToolBar[] loadToolBars() throws InvalidUIConfigurationException
public StatusBar createStatusBar()
public SplashScreen createSplashScreen()
public void updateAccessibleMenus(String accessibleName)
```

#### ResourceConst, PropertyConst, Const

- **역할**: UI 리소스/설정/이벤트/언어/환경설정 등에서 사용하는 문자열 상수 집합
- **설계**: 코드 하드코딩 방지, 일관성 및 유지보수성 강화

**상수 예시:**
| 상수명 | 설명 |
|--------|------|
| MENU_ITEMS | 메뉴 항목 키 |
| STATUSBAR_FONT_NAME | 상태바 폰트명 |
| MSG_APP_INIT | 애플리케이션 초기화 메시지 키 |

---

### 2. UI 프레임워크 및 컴포넌트

#### UIApplication, MDIApplication, SDIApplication

- **UIApplication**: UI 라이프사이클(초기화, 종료, 리소스 로딩, 이벤트 처리 등) 관리의 추상 기반 클래스
- **MDIApplication**: 다중 문서 인터페이스(MDI) 환경의 표준화 및 윈도우/데스크톱 관리
- **SDIApplication**: 단일 문서 인터페이스(SDI) 환경의 추상 기반(구체 기능 없음, 타입 계층 구분자)

#### SwingApplication

- **역할**: Swing 컴포넌트 생성, 다이얼로그, 스타일, 레이아웃, 이벤트 처리 등 UI 개발의 표준 템플릿/유틸리티 제공
- **특징**: 정적 메서드 중심, 다양한 컴포넌트/다이얼로그/스타일 생성 지원

**컴포넌트 생성 예시:**
```java
public static JFrame createFrame(String title, int width, int height)
public static JButton createButton(String text, Icon icon)
public static JProgressBar createProgressBar(int orient, int min, int max)
public static void info(Component parent, Object message, String title)
```

#### StatusBar, SplashScreen, ToolbarButton

- **StatusBar**: 상태 메시지/진행바 표시, 프로퍼티 변경 이벤트 기반 동적 갱신
- **SplashScreen**: 애플리케이션 시작 시 로딩 상태 안내, 상태 메시지 동적 갱신, 클릭 종료
- **ToolbarButton**: 툴바 버튼 커스터마이즈, 상태바와의 연동(마우스 오버 시 상태 메시지 표시)

---

### 3. MDI/데스크톱/윈도우 관리

#### WindowManager, Window

- **WindowManager**: 창(Window, JInternalFrame 등) 생성/등록/배치/상태관리/메뉴 동기화의 중앙 컨트롤러
- **Window**: 내부 프레임의 표준화, 상태 전환(최소화/최대화/복원/닫기), WindowManager와의 연동

#### ScrollableDesktopPane, DesktopScrollPane, BaseDesktopPane, BaseDesktopManager

- **ScrollableDesktopPane**: 스크롤 가능한 데스크톱 영역 제공(JDesktopPane + DesktopScrollPane)
- **DesktopScrollPane**: 내부 프레임의 추가/이동/크기 변경에 따라 스크롤 영역 자동 조정
- **BaseDesktopPane**: 데스크톱과 스크롤 패널의 연동, 뷰포트 정보 제공
- **BaseDesktopManager**: 내부 프레임의 상태(최대화/활성화/닫기) 커스터마이즈, 데스크톱 패널과의 연계

---

### 4. 테이블/레이아웃/그래프/파일 브라우저

#### BaseTableModel

- **역할**: Swing TableModel 표준 구현, 컬럼명/데이터/편집 가능성 관리, 데이터 변경 시 UI 동기화

| 메서드 | 설명 |
|--------|------|
| getColumnCount() | 컬럼 개수 반환 |
| getRowCount() | 행 개수 반환 |
| getValueAt(row, col) | 셀 값 조회 |
| setValueAt(value, row, col) | 셀 값 수정 및 UI 갱신 |

#### GridLayout2, AbsoluteLayout, AbsoluteConstraints

- **GridLayout2**: 각 행/열마다 컴포넌트의 선호 크기를 반영하는 유연한 그리드 레이아웃
- **AbsoluteLayout/AbsoluteConstraints**: 컴포넌트의 위치/크기를 절대 좌표로 지정하는 레이아웃 매니저 및 제약조건 객체

#### FSBrowserRenderer

- **역할**: 파일 시스템 브라우저 트리에서 파일/폴더/루트 노드별로 아이콘을 동적으로 지정하는 커스텀 렌더러
- **특징**: 파일 유형별 아이콘 매핑, 아이콘 캐싱, 외부 파일 유형 판별 로직 위임

---

### 5. 이벤트 및 라이프사이클 관리

#### JEventManager, JEventListener, ApplicationListener, ApplicationAdapter, JEvent, ApplicationEvent

- **JEventManager**: 싱글턴 이벤트 허브, 다양한 타입의 이벤트 리스너 등록/해제/분배, 리플렉션 기반 동적 이벤트 분배
- **JEventListener**: 마커 인터페이스, 커스텀 이벤트 리스너 계층의 최상위 타입
- **ApplicationListener**: 애플리케이션 초기화/종료 이벤트 콜백 인터페이스
- **ApplicationAdapter**: 기본 구현(로그 출력) 제공, 하위 클래스에서 오버라이드 확장 가능
- **JEvent/ApplicationEvent**: 이벤트 객체의 소스 관리, 타입 식별, 이벤트 계층 구조의 기반

**이벤트 분배 시퀀스 다이어그램 예시:**
```mermaid
sequenceDiagram
    participant Sender as 이벤트 송신자
    participant JEventManager as JEventManager
    participant Listener as ApplicationListener 구현체

    Sender->>JEventManager: fireEvent(ApplicationListener, ApplicationEvent, "applicationInit")
    activate JEventManager
    JEventManager->>Listener: applicationInit(ApplicationEvent)
    deactivate JEventManager
```

---

### 6. 코드/화면/설정/페이징 관리

#### CodeManager

- **역할**: 코드 테이블(major/minor code) 관리, 코드명/표시명/관계코드/다국어 지원, 코드 기반 콤보박스 동적 생성

#### ScreenManager, Screen

- **ScreenManager**: 화면 정의 XML을 로딩/캐싱, 화면 이름별 Screen 객체 제공, 다국어/다채널 지원
- **Screen**: 화면 이름, 블록 데이터, 블록 타입 정보의 데이터 컨테이너

#### JProperties, JPropertiesException

- **JProperties**: 설정값의 타입 안전한 조회/저장, 파일 로딩, 예외 처리 강화
- **JPropertiesException**: 설정 관련 예외의 구조화 및 명확한 구분

#### PagedList

- **역할**: 대량 데이터의 페이지 단위 관리, 페이징 정보(전체 건수, 현재 페이지 데이터, 페이지당 행 수 등) 캡슐화, 페이징 UI 생성 지원

---

### 7. 범용 유틸리티 및 보안

#### Util

- **역할**: 데이터 변환, 날짜/시간/숫자 포맷팅, 문자열 치환/분할, 입력값 검증(XSS/SQL Injection/OS Command Injection/HTTP Response Splitting 등), 환경설정 로딩, DB 권한 체크 등 범용 유틸리티 제공
- **특징**: 정적 메서드 중심, 보안 내재화, 환경 적응성, 실무적 요구 반영

---

## 주요 데이터 흐름 및 시퀀스

### 메뉴/툴바/상태바 동적 생성 및 접근성 제어

```mermaid
sequenceDiagram
    participant UIApplication as UIApplication
    participant ResourceManager as ResourceManager
    participant JMenuBar as JMenuBar
    participant JToolBar as JToolBar
    participant StatusBar as StatusBar

    UIApplication->>ResourceManager: loadMenuBar()
    activate ResourceManager
    ResourceManager->>JMenuBar: (생성 및 반환)
    deactivate ResourceManager
    UIApplication->>ResourceManager: loadToolBars()
    activate ResourceManager
    ResourceManager->>JToolBar: (생성 및 반환)
    deactivate ResourceManager
    UIApplication->>ResourceManager: createStatusBar()
    activate ResourceManager
    ResourceManager->>StatusBar: (생성 및 반환)
    deactivate ResourceManager
```

---

### 이벤트 분배 및 라이프사이클 관리

```mermaid
sequenceDiagram
    participant UIApplication as UIApplication
    participant JEventManager as JEventManager
    participant ApplicationListener as ApplicationListener

    UIApplication->>JEventManager: fireEvent(ApplicationListener, ApplicationEvent, "applicationInit")
    activate JEventManager
    JEventManager->>ApplicationListener: applicationInit(ApplicationEvent)
    deactivate JEventManager
```

---

## 주요 테이블 요약

### UI 리소스/설정 주요 상수

| 상수명 | 타입 | 설명 |
|--------|------|------|
| MENU_ITEMS | String | 메뉴 항목 키 |
| TOOLBAR_ITEMS | String | 툴바 항목 키 |
| STATUSBAR_FONT_NAME | String | 상태바 폰트명 |
| SPLASH_IMAGE | String | 스플래시 이미지 경로 |
| MSG_APP_INIT | String | 애플리케이션 초기화 메시지 키 |

---

### 주요 API/컴포넌트 요약

| 컴포넌트 | 역할 | 주요 메서드/필드 |
|----------|------|-----------------|
| ResourceManager | UI 리소스/설정/접근성 관리 | getString, loadMenuBar, loadToolBars, createStatusBar, updateAccessibleMenus |
| UIApplication | UI 라이프사이클/상태 관리 | init, destroy, loadResources, getMenuBar, getStatusBar |
| WindowManager | 창(Window) 관리 | createWindow, registerWindow, tileWindows, cascadeWindows, getWindowMenu |
| StatusBar | 상태 메시지/진행바 표시 | setStatusText, createProgressBar, firePropertyChange |
| JEventManager | 이벤트 리스너 관리/분배 | addJEventListener, removeJEventListener, fireEvent |
| BaseTableModel | 테이블 데이터 모델 | getRowCount, getColumnCount, getValueAt, setValueAt |
| Util | 범용 유틸리티/보안 | toInt, formatDate, isNotValidXSS, getPropertiesFromFile |

---

### 설정 파일/리소스 번들 구조 예시

```properties
# swing_ko.properties
menu.items=FILE,EDIT,VIEW,HELP
menu.FILE.text=파일
menu.FILE.mnemonic=F
menu.FILE.items=NEW,OPEN,SAVE,SEPARATOR,EXIT
menu.FILE.items.NEW.text=새로 만들기
menu.FILE.items.NEW.mnemonic=N
menu.FILE.items.NEW.actionClass=com.pjedf.df.action.NewFileAction
...
toolbar.items=MAIN,EDIT
toolbar.MAIN.menuItems=FILE.NEW,FILE.OPEN,FILE.SAVE
toolbar.MAIN.floatable=true
toolbar.MAIN.orientation=horizontal
...
statusbar.text.width=80%
statusbar.font.name=SansSerif
statusbar.font.size=12
statusbar.font.style=plain
statusbar.progressbar=true
```

---

## 결론 및 요약

본 시스템은 **Swing 기반 데스크톱 애플리케이션의 UI 리소스/설정/접근성/컴포넌트 생성/이벤트/테이블/그래프/파일 브라우저/보안/환경 관리**를 통합적으로 지원하는 견고한 프레임워크입니다.

- **중앙 집중적 리소스/설정 관리**(ResourceManager, ResourceConst)
- **동적/설정 기반 UI 생성 및 권한 제어**(메뉴/툴바/상태바 등)
- **MDI/SDI 프레임워크와 창 관리**(UIApplication, MDIApplication, WindowManager)
- **이벤트 기반 아키텍처와 라이프사이클 관리**(JEventManager, ApplicationListener)
- **테이블/레이아웃/그래프/파일 브라우저 등 다양한 UI 컴포넌트**
- **범용 유틸리티 및 보안 내재화**(Util)
- **확장성/유지보수성/국제화/테마/테스트 용이성 등 실무적 요구 반영**

향후에는 **제네릭/최신 API/모듈화/테스트/보안 정책 외부화/로깅 표준화** 등 현대적 소프트웨어 품질을 위한 구조적 개선이 권장됩니다.

**본 문서는 각 컴포넌트의 역할, 데이터 흐름, 아키텍처 구조, 확장성, 개선점까지 명확히 제시하여,
개발자들이 시스템을 빠르게 이해하고, 유지보수 및 확장에 효과적으로 대응할 수 있도록 돕습니다.**', '{}', '2025-06-24 00:27:06.881323 +00:00', null, '2025-06-24 00:27:06.881323 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('60be7706-a920-4738-a600-30cc390d246c', e'# GPU 대시보드 프로젝트 개요

## Introduction

GPU 대시보드 프로젝트는 Kubernetes 클러스터 내 GPU 자원 및 Pod 상태를 실시간으로 모니터링하고, 효율적으로 관리할 수 있는 대시보드 시스템을 구축하는 것을 목표로 합니다. 본 시스템은 Spring Boot 기반의 계층화된 아키텍처를 바탕으로, 클러스터 상태 수집, 데이터 저장, REST API 제공, 사용자 요청 처리 등 클라우드 환경에서 GPU 자원 활용도를 극대화하는 데 필요한 핵심 기능을 제공합니다.

각 패키지는 명확한 책임과 역할을 갖고 모듈화되어 있으며, 환경설정, 클러스터 연동, 데이터 동기화, API 인터페이스, 데이터 저장소 관리 등 전체 시스템의 신뢰성, 확장성, 유지보수성을 높이기 위한 설계 원칙을 충실히 따릅니다.

### 전체 시스템 의존성 흐름

아래 Mermaid.js 다이어그램은 GPU 대시보드 시스템의 주요 계층별 역할과 의존성 흐름을 시각화한 것입니다.

```mermaid
graph TD
    subgraph "Configuration Layer"
        Application["Application (Bootstrap)"]
        K8sConfig["K8sConfig (CoreV1Api Bean)"]
        SchedulerConfig["SchedulerConfig"]
    end
    subgraph "Controller Layer"
        PodController["PodController"]
    end
    subgraph "Service Layer"
        PodService["PodService"]
    end
    subgraph "Data Access Layer"
        PodInfoRepository["PodInfoRepository"]
    end
    subgraph "Domain Layer"
        PodInfoEntity["PodInfoEntity"]
        PodInfoDto["PodInfoDto"]
        PodResponseDto["PodResponseDto"]
        DeletePodRequest["DeletePodRequest"]
        DeletePodResponseDto["DeletePodResponseDto"]
        PodUpdateUserDto["PodUpdateUserDto"]
        NamespaceDto["NamespaceDto"]
    end
    subgraph "Infrastructure Layer"
        CoreV1Api["CoreV1Api"]
    end

    Application --> K8sConfig
    Application --> SchedulerConfig
    K8sConfig --> CoreV1Api
    SchedulerConfig --> PodService
    PodController --> PodService
    PodService --> PodInfoRepository
    PodService --> CoreV1Api
    PodInfoRepository --> PodInfoEntity
    PodService --> PodInfoDto
    PodService --> PodResponseDto
    PodService --> DeletePodResponseDto
    PodService --> PodUpdateUserDto
    PodService --> NamespaceDto
```
*설명: Application이 시스템을 부트스트랩하며, K8sConfig에서 Kubernetes API 클라이언트를 구성합니다. SchedulerConfig는 주기적으로 PodService를 호출하여 데이터를 갱신합니다. PodController는 클라이언트 요청을 받아 PodService에 위임하며, PodService는 데이터베이스(PodInfoRepository)와 Kubernetes API(CoreV1Api)에 모두 접근하여 데이터를 동기화합니다.*

---

## 시스템 구성 및 아키텍처

### 1. Application (시스템 부트스트랩)

- Spring Boot 애플리케이션의 진입점입니다.
- 환경 프로파일(`spring.profiles.active`)을 "dev"로 하드코딩하여 개발 환경을 활성화합니다.
- JPA 엔티티 스캔, 리포지토리 활성화, 스케줄링 활성화 등 시스템 기반 설정을 담당합니다.

```java
@SpringBootApplication
@EntityScan(basePackages = "com.example.gpu_dashboard.entity")
@EnableJpaRepositories(basePackages = "com.example.gpu_dashboard.repository")
@EnableScheduling
public class Application {
    public static void main(String[] args) {
        System.setProperty("spring.profiles.active", "dev");
        SpringApplication.run(Application.class, args);
    }
}
```

| 항목              | 설명                                                      |
|-------------------|-----------------------------------------------------------|
| 클래스명          | Application                                               |
| 주요 어노테이션   | @SpringBootApplication, @EntityScan, @EnableJpaRepositories, @EnableScheduling |
| 환경 프로파일     | dev (하드코딩)                                            |

---

### 2. K8sConfig (Kubernetes API 클라이언트 구성)

- Kubernetes 클러스터와의 연결을 담당하는 CoreV1Api 빈을 생성합니다.
- 클러스터 내부 인증, 클래스패스 kube_config.yaml, 외부 경로, 기본 경로 등 다양한 인증 방법을 순차적으로 시도합니다.
- Spring @Configuration 및 @Bean을 통해 싱글톤으로 관리됩니다.

```java
@Configuration
public class K8sConfig {
    @Value("${kubeconfig.path:#{null}}")
    private String kubeconfigPath;

    @Bean
    public CoreV1Api coreV1Api() throws IOException {
        ApiClient client;
        try {
            client = ClientBuilder.cluster().build();
            System.out.println("Kubernetes 클러스터에 연결되었습니다.");
        } catch (Exception e) {
            System.out.println("클러스터 내부 인증 실패, 외부 구성으로 시도합니다: " + e.getMessage());
            try {
                ClassPathResource resource = new ClassPathResource("kube_config.yaml");
                if (resource.exists()) {
                    InputStreamReader reader = new InputStreamReader(resource.getInputStream());
                    client = ClientBuilder.kubeconfig(KubeConfig.loadKubeConfig(reader)).build();
                    System.out.println("클래스패스에서 kube_config.yaml을 로드했습니다.");
                } else if (kubeconfigPath != null) {
                    client = ClientBuilder.kubeconfig(KubeConfig.loadKubeConfig(new FileReader(kubeconfigPath))).build();
                    System.out.println("지정된 경로에서 kubeconfig를 로드했습니다: " + kubeconfigPath);
                } else {
                    client = ClientBuilder.defaultClient();
                    System.out.println("기본 kubeconfig를 로드했습니다.");
                }
            } catch (Exception ex) {
                System.out.println("모든 인증 방법 실패, 최후의 방법으로 defaultClient 시도: " + ex.getMessage());
                client = io.kubernetes.client.openapi.Configuration.getDefaultApiClient();
            }
        }
        io.kubernetes.client.openapi.Configuration.setDefaultApiClient(client);
        return new CoreV1Api(client);
    }
}
```

| 옵션명           | 타입   | 기본값 | 설명                                 |
|------------------|--------|--------|--------------------------------------|
| kubeconfig.path  | String | null   | 외부 kubeconfig 파일 경로 (선택적)   |

---

### 3. SchedulerConfig (주기적 Pod 정보 갱신)

- 2분(120초)마다 지정된 네임스페이스(aidx, abclab, mattermost)의 Pod 정보를 조회 및 갱신합니다.
- PodService를 생성자 주입받아 사용하며, 각 네임스페이스별로 예외를 독립적으로 처리합니다.

```java
@Configuration
@EnableScheduling
public class SchedulerConfig {

    private static final Logger logger = LoggerFactory.getLogger(SchedulerConfig.class);

    private final PodService podService;
    private final List<String> monitoredNamespaces = Arrays.asList("aidx", "abclab", "mattermost");

    @Autowired
    public SchedulerConfig(PodService podService) {
        this.podService = podService;
    }

    @Scheduled(fixedRate = 120000)
    public void updatePodInfo() {
        logger.info("Scheduled pod info update started");
        for (String namespace : monitoredNamespaces) {
            try {
                podService.listPods(namespace);
                logger.debug("Updated pod info for namespace: {}", namespace);
            } catch (Exception e) {
                logger.error("Failed to update pod info for namespace {}: {}", namespace, e.getMessage());
            }
        }
        logger.info("Scheduled pod info update completed");
    }
}
```

| 항목                 | 값/설명                                   |
|----------------------|--------------------------------------------|
| 스케줄 주기          | 120,000ms (2분)                            |
| 모니터링 네임스페이스 | aidx, abclab, mattermost (하드코딩)        |

---

### 4. Controller Layer (PodController)

- 클라이언트의 REST API 요청을 받아 Pod 관련 비즈니스 로직을 PodService에 위임합니다.
- 주요 엔드포인트:
  - `/pods` : 네임스페이스 내 Pod 목록 조회 및 DB 저장
  - `/pods/db` : DB에서 Pod 목록 조회
  - `/pods/delete` : Pod 삭제
  - `/pods/update/username` : Pod 사용자 이름 변경

```java
@PostMapping("/pods/delete")
public DeletePodResponseDto deletePod(@RequestBody DeletePodRequest request) {
    try {
        logger.debug("Pod 삭제 요청 - namespace: {}, podName: {}",
            request.getNamespace(), request.getPodName());
        return podService.deletePod(request.getNamespace(), request.getPodName());
    } catch (Exception e) {
        logger.error("Pod 삭제 중 오류 발생: ", e);
        return new DeletePodResponseDto("fail");
    }
}
```

| 엔드포인트                | HTTP | 요청 DTO           | 응답 DTO               | 설명                       |
|---------------------------|------|--------------------|------------------------|----------------------------|
| /pods                     | POST | NamespaceDto       | PodResponseDto         | 네임스페이스 내 Pod 목록 조회 및 DB 저장 |
| /pods/db                  | POST | NamespaceDto       | PodResponseDto         | DB에서 Pod 목록 조회       |
| /pods/delete              | POST | DeletePodRequest   | DeletePodResponseDto   | Pod 삭제                   |
| /pods/update/username     | POST | PodUpdateUserDto   | PodResponseDto         | Pod 사용자 이름 변경       |

---

### 5. Service Layer (PodService)

- Kubernetes API(CoreV1Api)와 데이터베이스(PodInfoRepository)를 연동하여 Pod 상태를 실시간으로 수집, 동기화, 관리합니다.
- Pod 정보 저장, 삭제, 상태 갱신, 사용자 정보 업데이트 등 핵심 비즈니스 로직을 담당합니다.

```java
public PodResponseDto listPods(String namespace) throws Exception {
    V1PodList podList = coreV1Api.listNamespacedPod(
        namespace != null ? namespace.trim() : "",
        null, null, null, null, null, null, null, null, null, false
    );
    Set<String> currentPodNames = podList.getItems().stream()
        .map(pod -> pod.getMetadata().getName())
        .collect(Collectors.toSet());

    List<PodInfoEntity> dbPods = podInfoRepository.findByNamespace(namespace);
    for (PodInfoEntity dbPod : dbPods) {
        if (!currentPodNames.contains(dbPod.getPodName())) {
            podInfoRepository.delete(dbPod);
        }
    }

    List<PodInfoDto> podInfos = podList.getItems().stream()
        .map(pod -> {
            // ... Pod 정보 추출 및 가공 ...
            savePodInfo(namespace, podName, podPhase, poduptime, gpuDevices);
            return new PodInfoDto(namespace, podName, podPhase, poduptime, gpuDevices, username);
        })
        .collect(Collectors.toList());

    return new PodResponseDto(podInfos);
}
```

| 메서드명                  | 설명                                                         |
|---------------------------|--------------------------------------------------------------|
| listPods(namespace)       | 네임스페이스 내 Pod 목록 조회 및 DB 동기화                   |
| getPodsFromDb(namespace)  | DB에서 Pod 정보 조회                                         |
| deletePod(namespace, pod) | Kubernetes 및 DB에서 Pod 삭제                                |
| updatePodStatusInDb(...)  | Pod 상태를 DB에 반영 (내부용)                                |
| updateUsername(...)       | Pod의 사용자 이름 정보 갱신                                  |

---

### 6. Data Access Layer (PodInfoRepository)

- PodInfoEntity에 대한 데이터베이스 접근을 담당하는 JPA 리포지토리 인터페이스입니다.
- 네임스페이스별 Pod 목록 조회, 네임스페이스+Pod 이름으로 특정 Pod 상세 조회 기능을 제공합니다.

```java
public interface PodInfoRepository extends JpaRepository<PodInfoEntity, Long> {
    List<PodInfoEntity> findByNamespace(String namespace);
    Optional<PodInfoEntity> findByNamespaceAndPodName(String namespace, String podName);
}
```

| 메서드명                           | 파라미터                  | 반환 타입                  | 설명                                 |
|-------------------------------------|---------------------------|---------------------------|--------------------------------------|
| findByNamespace                     | String namespace          | List<PodInfoEntity>       | 네임스페이스별 Pod 목록 조회         |
| findByNamespaceAndPodName           | String namespace, String podName | Optional<PodInfoEntity> | 네임스페이스+Pod 이름으로 Pod 조회   |

---

### 7. Domain/DTO 계층

#### PodInfoEntity

| 필드명         | 타입             | 제약조건/설명           |
|----------------|------------------|------------------------|
| id             | Long             | PK, 자동 증가          |
| username       | String           | 사용자 이름            |
| namespace      | String           | 네임스페이스           |
| podName        | String           | Pod 이름               |
| podStatus      | String           | Pod 상태               |
| gpuDevices     | String           | GPU 장치 정보          |
| podUptime      | String           | Pod 가동 시간          |
| startDateTime  | LocalDateTime    | Pod 시작 시각          |

#### PodInfoDto

| 필드명      | 타입    | 설명                |
|-------------|---------|---------------------|
| namespace   | String  | 네임스페이스        |
| podname     | String  | Pod 이름            |
| podstatus   | String  | Pod 상태            |
| poduptime   | String  | Pod 가동 시간       |
| gpuDevices  | String  | GPU 장치 정보       |
| username    | String  | 사용자명            |

#### PodResponseDto

```java
public class PodResponseDto {
    private List<PodInfoDto> result;
    public PodResponseDto(List<PodInfoDto> result) { this.result = result; }
    public List<PodInfoDto> getResult() { return result; }
}
```

#### DeletePodRequest / DeletePodResponseDto

| 클래스명               | 필드/메서드            | 설명                       |
|-----------------------|------------------------|----------------------------|
| DeletePodRequest      | namespace, podName     | 삭제 대상 Pod 식별         |
| DeletePodResponseDto  | status                 | 삭제 결과("success"/"fail")|

#### PodUpdateUserDto

| 필드명     | 타입    | 설명         |
|------------|---------|--------------|
| namespace  | String  | 네임스페이스 |
| podname    | String  | Pod 이름     |
| username   | String  | 사용자명     |

#### NamespaceDto

| 필드명     | 타입    | 설명         |
|------------|---------|--------------|
| namespace  | String  | 네임스페이스 |

---

## 데이터 및 서비스 흐름 다이어그램

아래는 주요 서비스 흐름을 시각화한 다이어그램입니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        SchedulerConfig["SchedulerConfig"]
        PodController["PodController"]
    end
    subgraph "Business Layer"
        PodService["PodService"]
    end
    subgraph "Data Layer"
        PodInfoRepository["PodInfoRepository"]
    end
    subgraph "Infrastructure Layer"
        K8sConfig["K8sConfig (CoreV1Api)"]
        CoreV1Api["CoreV1Api"]
    end

    SchedulerConfig --> PodService
    PodController --> PodService
    PodService --> PodInfoRepository
    PodService --> CoreV1Api
    K8sConfig --> CoreV1Api
```
*설명: SchedulerConfig가 주기적으로 PodService를 호출하며, PodController는 클라이언트 요청을 PodService에 위임합니다. PodService는 데이터베이스와 Kubernetes API 모두에 접근하여 데이터를 동기화합니다.*

---

## 주요 기능 및 API 요약

| 기능/엔드포인트            | 요청 DTO/파라미터         | 응답 DTO/타입           | 설명                        |
|--------------------------|--------------------------|-------------------------|-----------------------------|
| Pod 목록 조회            | NamespaceDto             | PodResponseDto          | 네임스페이스별 Pod 목록 조회|
| Pod DB 조회              | NamespaceDto             | PodResponseDto          | DB 기준 Pod 목록 조회       |
| Pod 삭제                 | DeletePodRequest         | DeletePodResponseDto    | Pod 삭제 요청 및 결과 반환  |
| Pod 사용자명 갱신        | PodUpdateUserDto         | PodResponseDto          | Pod 사용자 정보 변경        |

---

## 설정 옵션 요약

| 설정 항목         | 타입    | 기본값 | 설명                                 |
|-------------------|---------|--------|--------------------------------------|
| spring.profiles.active | String | dev    | 활성화할 Spring 프로파일             |
| kubeconfig.path   | String  | null   | 외부 kubeconfig 파일 경로 (선택적)   |

---

## 결론

GPU 대시보드 프로젝트는 Kubernetes 클러스터의 GPU 및 Pod 상태를 실시간으로 모니터링하고, 데이터베이스와의 정합성을 유지하는 구조적이고 확장 가능한 시스템입니다. 환경별 유연한 설정, 안정적인 클러스터 연동, 주기적 데이터 동기화, 명확한 계층 분리 등은 시스템의 신뢰성과 유지보수성을 높이는 핵심 요소입니다.
향후 환경 변수 기반 설정, 네임스페이스 동적 관리, 인증 방식 다양화 등으로 확장성을 더욱 강화할 수 있습니다. 본 시스템은 GPU 자원 모니터링 및 클러스터 관리 분야에서 신뢰성 높은 솔루션을 제공하는 핵심 인프라로서, 비즈니스 가치를 극대화하는 데 적합한 설계입니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('15bdd145-9962-4077-bf86-cd14e8921fd5', e'# GPU 대시보드 구성

## Introduction

GPU 대시보드는 Kubernetes 클러스터 내 GPU 리소스 및 Pod 상태를 실시간으로 모니터링하고 관리하는 Spring Boot 기반의 웹 애플리케이션입니다. 본 시스템은 클러스터와의 안정적인 연결, 주기적인 상태 동기화, 데이터 저장 및 관리, 그리고 사용자 요청에 따른 Pod 제어 기능을 제공합니다.
아키텍처는 환경별 유연한 설정, 인프라 계층의 Kubernetes API 연동, 서비스 계층의 비즈니스 로직, 그리고 스케줄러를 통한 자동화된 데이터 갱신 등으로 구성되어 있습니다.

아래 다이어그램은 전체 시스템의 주요 레이어와 의존성 흐름을 시각적으로 보여줍니다.

```mermaid
graph TD
    subgraph "Configuration Layer"
        K8sConfig["K8sConfig (CoreV1Api Bean)"]
        SchedulerConfig["SchedulerConfig"]
        Application["Application (Bootstrap)"]
    end
    subgraph "Service Layer"
        PodService["PodService"]
    end
    subgraph "Data Access Layer"
        PodInfoRepository["PodInfoRepository"]
    end

    Application --> K8sConfig
    Application --> SchedulerConfig
    K8sConfig --> PodService
    SchedulerConfig --> PodService
    PodService --> PodInfoRepository
```
*설명: Application이 시스템을 부트스트랩하며, K8sConfig에서 Kubernetes API 클라이언트를 구성합니다. SchedulerConfig는 주기적으로 PodService를 호출하여 데이터를 갱신합니다. PodService는 데이터베이스 접근을 위해 PodInfoRepository에 의존합니다.*

---

## 시스템 구성요소 및 상세 설명

### 1. Application (시스템 부트스트랩)

#### 역할 및 기능
- Spring Boot 애플리케이션의 진입점입니다.
- JVM 시스템 속성 `spring.profiles.active`를 `"dev"`로 설정하여 개발 환경 프로파일을 활성화합니다.
- `SpringApplication.run()`을 호출하여 전체 시스템을 구동합니다.

#### 주요 코드 스니펫
```java
@SpringBootApplication
@EntityScan(basePackages = "com.example.gpu_dashboard.entity")
@EnableJpaRepositories(basePackages = "com.example.gpu_dashboard.repository")
@EnableScheduling
public class Application {
    public static void main(String[] args) {
        System.setProperty("spring.profiles.active", "dev");
        SpringApplication.run(Application.class, args);
    }
}
```

| 항목              | 설명                                                      |
|-------------------|-----------------------------------------------------------|
| 클래스명          | Application                                               |
| 주요 어노테이션   | @SpringBootApplication, @EntityScan, @EnableJpaRepositories, @EnableScheduling |
| 주요 기능         | 시스템 부트스트랩, 환경 프로파일 지정, 컨텍스트 생성       |
| 환경 프로파일     | dev (코드 내 하드코딩)                                    |

---

### 2. K8sConfig (Kubernetes API 클라이언트 구성)

#### 역할 및 기능
- Kubernetes 클러스터와의 연결을 담당하는 CoreV1Api 빈을 생성합니다.
- 다양한 인증 방법(클러스터 내부, 클래스패스 kube_config.yaml, 지정 경로, 기본 경로)을 순차적으로 시도하여 연결 안정성을 높입니다.
- Spring @Configuration 및 @Bean을 통해 싱글톤으로 관리됩니다.

#### 주요 코드 스니펫
```java
@Configuration
public class K8sConfig {
    @Value("${kubeconfig.path:#{null}}")
    private String kubeconfigPath;

    @Bean
    public CoreV1Api coreV1Api() throws IOException {
        ApiClient client;
        try {
            client = ClientBuilder.cluster().build();
            System.out.println("Kubernetes 클러스터에 연결되었습니다.");
        } catch (Exception e) {
            System.out.println("클러스터 내부 인증 실패, 외부 구성으로 시도합니다: " + e.getMessage());
            try {
                ClassPathResource resource = new ClassPathResource("kube_config.yaml");
                if (resource.exists()) {
                    InputStreamReader reader = new InputStreamReader(resource.getInputStream());
                    client = ClientBuilder.kubeconfig(KubeConfig.loadKubeConfig(reader)).build();
                    System.out.println("클래스패스에서 kube_config.yaml을 로드했습니다.");
                } else if (kubeconfigPath != null) {
                    client = ClientBuilder.kubeconfig(KubeConfig.loadKubeConfig(new FileReader(kubeconfigPath))).build();
                    System.out.println("지정된 경로에서 kubeconfig를 로드했습니다: " + kubeconfigPath);
                } else {
                    client = ClientBuilder.defaultClient();
                    System.out.println("기본 kubeconfig를 로드했습니다.");
                }
            } catch (Exception ex) {
                System.out.println("모든 인증 방법 실패, 최후의 방법으로 defaultClient 시도: " + ex.getMessage());
                client = io.kubernetes.client.openapi.Configuration.getDefaultApiClient();
            }
        }
        io.kubernetes.client.openapi.Configuration.setDefaultApiClient(client);
        return new CoreV1Api(client);
    }
}
```

| 옵션명           | 타입   | 기본값 | 설명                                 |
|------------------|--------|--------|--------------------------------------|
| kubeconfig.path  | String | null   | 외부 kubeconfig 파일 경로 (선택적)   |

---

### 3. SchedulerConfig (주기적 Pod 정보 갱신)

#### 역할 및 기능
- 2분(120초)마다 지정된 네임스페이스의 Pod 정보를 조회 및 갱신합니다.
- PodService를 생성자 주입받아 사용합니다.
- 각 네임스페이스별로 독립적으로 예외를 처리하여 전체 작업의 안정성을 확보합니다.

#### 주요 코드 스니펫
```java
@Configuration
@EnableScheduling
public class SchedulerConfig {

    private static final Logger logger = LoggerFactory.getLogger(SchedulerConfig.class);

    private final PodService podService;
    private final List<String> monitoredNamespaces = Arrays.asList("aidx", "abclab", "mattermost");

    @Autowired
    public SchedulerConfig(PodService podService) {
        this.podService = podService;
    }

    @Scheduled(fixedRate = 120000)
    public void updatePodInfo() {
        logger.info("Scheduled pod info update started");
        for (String namespace : monitoredNamespaces) {
            try {
                podService.listPods(namespace);
                logger.debug("Updated pod info for namespace: {}", namespace);
            } catch (Exception e) {
                logger.error("Failed to update pod info for namespace {}: {}", namespace, e.getMessage());
            }
        }
        logger.info("Scheduled pod info update completed");
    }
}
```

| 항목                 | 값/설명                                   |
|----------------------|--------------------------------------------|
| 스케줄 주기          | 120,000ms (2분)                            |
| 모니터링 네임스페이스 | aidx, abclab, mattermost (하드코딩)        |
| 의존 서비스          | PodService                                 |

---

### 4. PodService (비즈니스 로직 및 데이터 동기화)

#### 역할 및 기능
- Kubernetes API를 통해 Pod 목록을 조회하고, 데이터베이스와 동기화합니다.
- Pod 정보 저장, 삭제, 상태 갱신, 사용자 정보 업데이트 등 핵심 비즈니스 로직을 담당합니다.
- PodInfoRepository를 통해 데이터베이스에 접근합니다.

#### 주요 메서드 및 설명

| 메서드명                  | 설명                                                         |
|---------------------------|--------------------------------------------------------------|
| listPods(namespace)       | 네임스페이스 내 Pod 목록 조회 및 DB 동기화                   |
| getPodsFromDb(namespace)  | DB에서 Pod 정보 조회                                         |
| deletePod(namespace, pod) | Kubernetes 및 DB에서 Pod 삭제                                |
| updatePodStatusInDb(...)  | Pod 상태를 DB에 반영 (내부용)                                |
| updateUsername(...)       | Pod의 사용자 이름 정보 갱신                                  |

#### 주요 코드 스니펫 (listPods)
```java
public PodResponseDto listPods(String namespace) throws Exception {
    V1PodList podList = coreV1Api.listNamespacedPod(
        namespace != null ? namespace.trim() : "",
        null, null, null, null, null, null, null, null, null, false
    );
    // ... (중략) ...
    // 현재 쿠버네티스에 없는 Pod는 DB에서 삭제
    for (PodInfoEntity dbPod : dbPods) {
        if (!currentPodNames.contains(dbPod.getPodName())) {
            podInfoRepository.delete(dbPod);
        }
    }
    // Pod 정보 저장 및 DTO 변환
    List<PodInfoDto> podInfos = podList.getItems().stream()
        .map(pod -> {
            // ... (상태, 가동시간, GPU 정보 추출)
            savePodInfo(namespace, podName, podPhase, poduptime, gpuDevices);
            return new PodInfoDto(namespace, podName, podPhase, poduptime, gpuDevices, username);
        }).collect(Collectors.toList());
    return new PodResponseDto(podInfos);
}
```

| 단계         | 설명                                                         |
|--------------|--------------------------------------------------------------|
| 1. API 호출  | coreV1Api.listNamespacedPod로 Pod 목록 조회                  |
| 2. DB 조회   | podInfoRepository.findByNamespace로 DB 내 Pod 목록 조회      |
| 3. 동기화    | 쿠버네티스에 없는 Pod는 DB에서 삭제, 신규/변경 Pod는 저장    |
| 4. DTO 변환  | PodInfoDto로 변환 후 PodResponseDto로 감싸서 반환            |

---

### 5. 데이터 모델 및 주요 구조

#### PodInfoEntity

| 필드명      | 타입    | 제약조건/설명              |
|-------------|---------|---------------------------|
| namespace   | String  | 네임스페이스              |
| podName     | String  | Pod 이름                  |
| podStatus   | String  | Pod 상태                  |
| podUptime   | String  | 가동 시간                 |
| gpuDevices  | String  | GPU 장치 정보             |
| username    | String  | 사용자 이름               |

#### PodInfoDto

| 필드명      | 타입    | 설명                      |
|-------------|---------|---------------------------|
| namespace   | String  | 네임스페이스              |
| podName     | String  | Pod 이름                  |
| podStatus   | String  | Pod 상태                  |
| podUptime   | String  | 가동 시간                 |
| gpuDevices  | String  | GPU 장치 정보             |
| username    | String  | 사용자 이름               |

---

## 데이터 및 서비스 흐름 다이어그램

아래는 주요 서비스 흐름을 시각화한 다이어그램입니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        SchedulerConfig["SchedulerConfig"]
    end
    subgraph "Business Layer"
        PodService["PodService"]
    end
    subgraph "Data Layer"
        PodInfoRepository["PodInfoRepository"]
    end
    subgraph "Infrastructure Layer"
        K8sConfig["K8sConfig (CoreV1Api)"]
        CoreV1Api["CoreV1Api"]
    end

    SchedulerConfig --> PodService
    PodService --> PodInfoRepository
    PodService --> CoreV1Api
    K8sConfig --> CoreV1Api
```
*설명: SchedulerConfig가 주기적으로 PodService를 호출합니다. PodService는 데이터베이스(PodInfoRepository)와 Kubernetes API(CoreV1Api)에 모두 접근하여 데이터를 동기화합니다. CoreV1Api는 K8sConfig에서 구성됩니다.*

---

## API/설정 요약 표

### 주요 설정 옵션

| 설정 항목         | 타입    | 기본값 | 설명                                 |
|-------------------|---------|--------|--------------------------------------|
| spring.profiles.active | String | dev    | 활성화할 Spring 프로파일             |
| kubeconfig.path   | String  | null   | 외부 kubeconfig 파일 경로 (선택적)   |

### Scheduler 관련

| 항목                 | 값/설명                                   |
|----------------------|--------------------------------------------|
| 스케줄 주기          | 120,000ms (2분)                            |
| 모니터링 네임스페이스 | aidx, abclab, mattermost (하드코딩)        |

---

## 결론

GPU 대시보드 시스템은 Spring Boot 기반의 구조적이고 확장 가능한 아키텍처를 바탕으로, Kubernetes 클러스터의 GPU 및 Pod 상태를 실시간으로 모니터링하고 관리할 수 있도록 설계되었습니다.
환경별 유연한 설정, 안정적인 클러스터 연결, 주기적인 데이터 동기화, 명확한 서비스 계층 분리 등은 시스템의 신뢰성과 유지보수성을 높이는 핵심 요소입니다.
향후 환경 변수 기반 설정, 네임스페이스 동적 관리, 인증 방식 다양화 등으로 확장성을 더욱 강화할 수 있습니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('d103e5cc-a404-4d48-9000-dbc1025e5ecb', e'# GPU 대시보드 설정

## Introduction

GPU 대시보드는 Kubernetes 클러스터 내 GPU 리소스 및 Pod 상태를 실시간으로 모니터링하고 관리하는 Spring Boot 기반의 웹 애플리케이션입니다. 본 시스템은 클러스터와의 안정적인 연결, 주기적인 상태 동기화, 데이터 저장 및 관리, 그리고 사용자 요청에 따른 Pod 제어 기능을 제공합니다.
아키텍처는 환경별 유연한 설정, 인프라 계층의 Kubernetes API 연동, 서비스 계층의 비즈니스 로직, 그리고 스케줄러를 통한 자동화된 데이터 갱신 등으로 구성되어 있습니다.

아래 다이어그램은 전체 시스템의 주요 레이어와 의존성 흐름을 시각적으로 보여줍니다.

**아키텍처 레이어 및 의존성 흐름**

```mermaid
graph TD
    subgraph "Configuration Layer"
        K8sConfig["K8sConfig (CoreV1Api Bean)"]
        SchedulerConfig["SchedulerConfig"]
        Application["Application (Bootstrap)"]
    end
    subgraph "Service Layer"
        PodService["PodService"]
    end
    subgraph "Data Access Layer"
        PodInfoRepository["PodInfoRepository"]
    end

    Application --> K8sConfig
    Application --> SchedulerConfig
    K8sConfig --> PodService
    SchedulerConfig --> PodService
    PodService --> PodInfoRepository
```
*설명: Application이 시스템을 부트스트랩하며, K8sConfig에서 Kubernetes API 클라이언트를 구성합니다. SchedulerConfig는 주기적으로 PodService를 호출하여 데이터를 갱신합니다. PodService는 데이터베이스 접근을 위해 PodInfoRepository에 의존합니다.*

---

## 시스템 구성요소 및 상세 설명

### 1. Application (시스템 부트스트랩)

#### 역할 및 기능
- Spring Boot 애플리케이션의 진입점입니다.
- JVM 시스템 속성 `spring.profiles.active`를 `"dev"`로 설정하여 개발 환경 프로파일을 활성화합니다.
- `SpringApplication.run()`을 호출하여 전체 시스템을 구동합니다.

#### 주요 코드 스니펫
```java
@SpringBootApplication
@EntityScan(basePackages = "com.example.gpu_dashboard.entity")
@EnableJpaRepositories(basePackages = "com.example.gpu_dashboard.repository")
@EnableScheduling
public class Application {
    public static void main(String[] args) {
        System.setProperty("spring.profiles.active", "dev");
        SpringApplication.run(Application.class, args);
    }
}
```

#### 요약 표

| 항목              | 설명                                                      |
|-------------------|-----------------------------------------------------------|
| 클래스명          | Application                                               |
| 주요 어노테이션   | @SpringBootApplication, @EntityScan, @EnableJpaRepositories, @EnableScheduling |
| 주요 기능         | 시스템 부트스트랩, 환경 프로파일 지정, 컨텍스트 생성       |
| 환경 프로파일     | dev (코드 내 하드코딩)                                    |

---

### 2. K8sConfig (Kubernetes API 클라이언트 구성)

#### 역할 및 기능
- Kubernetes 클러스터와의 연결을 담당하는 CoreV1Api 빈을 생성합니다.
- 다양한 인증 방법(클러스터 내부, 클래스패스 kube_config.yaml, 지정 경로, 기본 경로)을 순차적으로 시도하여 연결 안정성을 높입니다.
- Spring @Configuration 및 @Bean을 통해 싱글톤으로 관리됩니다.

#### 주요 코드 스니펫
```java
@Configuration
public class K8sConfig {
    @Value("${kubeconfig.path:#{null}}")
    private String kubeconfigPath;

    @Bean
    public CoreV1Api coreV1Api() throws IOException {
        ApiClient client;
        try {
            client = ClientBuilder.cluster().build();
            System.out.println("Kubernetes 클러스터에 연결되었습니다.");
        } catch (Exception e) {
            System.out.println("클러스터 내부 인증 실패, 외부 구성으로 시도합니다: " + e.getMessage());
            try {
                ClassPathResource resource = new ClassPathResource("kube_config.yaml");
                if (resource.exists()) {
                    InputStreamReader reader = new InputStreamReader(resource.getInputStream());
                    client = ClientBuilder.kubeconfig(KubeConfig.loadKubeConfig(reader)).build();
                    System.out.println("클래스패스에서 kube_config.yaml을 로드했습니다.");
                } else if (kubeconfigPath != null) {
                    client = ClientBuilder.kubeconfig(KubeConfig.loadKubeConfig(new FileReader(kubeconfigPath))).build();
                    System.out.println("지정된 경로에서 kubeconfig를 로드했습니다: " + kubeconfigPath);
                } else {
                    client = ClientBuilder.defaultClient();
                    System.out.println("기본 kubeconfig를 로드했습니다.");
                }
            } catch (Exception ex) {
                System.out.println("모든 인증 방법 실패, 최후의 방법으로 defaultClient 시도: " + ex.getMessage());
                client = io.kubernetes.client.openapi.Configuration.getDefaultApiClient();
            }
        }
        io.kubernetes.client.openapi.Configuration.setDefaultApiClient(client);
        return new CoreV1Api(client);
    }
}
```

#### 설정 옵션 요약

| 옵션명           | 타입   | 기본값 | 설명                                 |
|------------------|--------|--------|--------------------------------------|
| kubeconfig.path  | String | null   | 외부 kubeconfig 파일 경로 (선택적)   |

---

### 3. SchedulerConfig (주기적 Pod 정보 갱신)

#### 역할 및 기능
- 2분(120초)마다 지정된 네임스페이스의 Pod 정보를 조회 및 갱신합니다.
- PodService를 생성자 주입받아 사용합니다.
- 각 네임스페이스별로 독립적으로 예외를 처리하여 전체 작업의 안정성을 확보합니다.

#### 주요 코드 스니펫
```java
@Configuration
@EnableScheduling
public class SchedulerConfig {

    private static final Logger logger = LoggerFactory.getLogger(SchedulerConfig.class);

    private final PodService podService;
    private final List<String> monitoredNamespaces = Arrays.asList("aidx", "abclab", "mattermost");

    @Autowired
    public SchedulerConfig(PodService podService) {
        this.podService = podService;
    }

    @Scheduled(fixedRate = 120000)
    public void updatePodInfo() {
        logger.info("Scheduled pod info update started");
        for (String namespace : monitoredNamespaces) {
            try {
                podService.listPods(namespace);
                logger.debug("Updated pod info for namespace: {}", namespace);
            } catch (Exception e) {
                logger.error("Failed to update pod info for namespace {}: {}", namespace, e.getMessage());
            }
        }
        logger.info("Scheduled pod info update completed");
    }
}
```

#### 주요 설정 요약

| 항목                 | 값/설명                                   |
|----------------------|--------------------------------------------|
| 스케줄 주기          | 120,000ms (2분)                            |
| 모니터링 네임스페이스 | aidx, abclab, mattermost (하드코딩)        |
| 의존 서비스          | PodService                                 |

---

### 4. PodService (비즈니스 로직 및 데이터 동기화)

#### 역할 및 기능
- Kubernetes API를 통해 Pod 목록을 조회하고, 데이터베이스와 동기화합니다.
- Pod 정보 저장, 삭제, 상태 갱신, 사용자 정보 업데이트 등 핵심 비즈니스 로직을 담당합니다.
- PodInfoRepository를 통해 데이터베이스에 접근합니다.

#### 주요 메서드 및 설명

| 메서드명                  | 설명                                                         |
|---------------------------|--------------------------------------------------------------|
| listPods(namespace)       | 네임스페이스 내 Pod 목록 조회 및 DB 동기화                   |
| getPodsFromDb(namespace)  | DB에서 Pod 정보 조회                                         |
| deletePod(namespace, pod) | Kubernetes 및 DB에서 Pod 삭제                                |
| updatePodStatusInDb(...)  | Pod 상태를 DB에 반영 (내부용)                                |
| updateUsername(...)       | Pod의 사용자 이름 정보 갱신                                  |

#### 주요 코드 스니펫 (listPods)

```java
public PodResponseDto listPods(String namespace) throws Exception {
    V1PodList podList = coreV1Api.listNamespacedPod(
        namespace != null ? namespace.trim() : "",
        null, null, null, null, null, null, null, null, null, false
    );
    // ... (중략) ...
    // 현재 쿠버네티스에 없는 Pod는 DB에서 삭제
    for (PodInfoEntity dbPod : dbPods) {
        if (!currentPodNames.contains(dbPod.getPodName())) {
            podInfoRepository.delete(dbPod);
        }
    }
    // Pod 정보 저장 및 DTO 변환
    List<PodInfoDto> podInfos = podList.getItems().stream()
        .map(pod -> {
            // ... (상태, 가동시간, GPU 정보 추출)
            savePodInfo(namespace, podName, podPhase, poduptime, gpuDevices);
            return new PodInfoDto(namespace, podName, podPhase, poduptime, gpuDevices, username);
        }).collect(Collectors.toList());
    return new PodResponseDto(podInfos);
}
```

#### 데이터 흐름 요약

| 단계         | 설명                                                         |
|--------------|--------------------------------------------------------------|
| 1. API 호출  | coreV1Api.listNamespacedPod로 Pod 목록 조회                  |
| 2. DB 조회   | podInfoRepository.findByNamespace로 DB 내 Pod 목록 조회      |
| 3. 동기화    | 쿠버네티스에 없는 Pod는 DB에서 삭제, 신규/변경 Pod는 저장    |
| 4. DTO 변환  | PodInfoDto로 변환 후 PodResponseDto로 감싸서 반환            |

---

### 5. 데이터 모델 및 주요 구조

#### PodInfoEntity (예상 구조)

| 필드명      | 타입    | 제약조건/설명              |
|-------------|---------|---------------------------|
| namespace   | String  | 네임스페이스              |
| podName     | String  | Pod 이름                  |
| podStatus   | String  | Pod 상태                  |
| podUptime   | String  | 가동 시간                 |
| gpuDevices  | String  | GPU 장치 정보             |
| username    | String  | 사용자 이름               |

#### PodInfoDto

| 필드명      | 타입    | 설명                      |
|-------------|---------|---------------------------|
| namespace   | String  | 네임스페이스              |
| podName     | String  | Pod 이름                  |
| podStatus   | String  | Pod 상태                  |
| podUptime   | String  | 가동 시간                 |
| gpuDevices  | String  | GPU 장치 정보             |
| username    | String  | 사용자 이름               |

---

## 데이터 및 서비스 흐름 다이어그램

아래는 주요 서비스 흐름을 시각화한 다이어그램입니다.

```mermaid
graph TD
    subgraph "Presentation Layer"
        SchedulerConfig["SchedulerConfig"]
    end
    subgraph "Business Layer"
        PodService["PodService"]
    end
    subgraph "Data Layer"
        PodInfoRepository["PodInfoRepository"]
    end
    subgraph "Infrastructure Layer"
        K8sConfig["K8sConfig (CoreV1Api)"]
        CoreV1Api["CoreV1Api"]
    end

    SchedulerConfig --> PodService
    PodService --> PodInfoRepository
    PodService --> CoreV1Api
    K8sConfig --> CoreV1Api
```
*설명: SchedulerConfig가 주기적으로 PodService를 호출합니다. PodService는 데이터베이스(PodInfoRepository)와 Kubernetes API(CoreV1Api)에 모두 접근하여 데이터를 동기화합니다. CoreV1Api는 K8sConfig에서 구성됩니다.*

---

## API/설정 요약 표

### 주요 설정 옵션

| 설정 항목         | 타입    | 기본값 | 설명                                 |
|-------------------|---------|--------|--------------------------------------|
| spring.profiles.active | String | dev    | 활성화할 Spring 프로파일             |
| kubeconfig.path   | String  | null   | 외부 kubeconfig 파일 경로 (선택적)   |

### Scheduler 관련

| 항목                 | 값/설명                                   |
|----------------------|--------------------------------------------|
| 스케줄 주기          | 120,000ms (2분)                            |
| 모니터링 네임스페이스 | aidx, abclab, mattermost (하드코딩)        |

---

## 결론

GPU 대시보드 시스템은 Spring Boot 기반의 구조적이고 확장 가능한 아키텍처를 바탕으로, Kubernetes 클러스터의 GPU 및 Pod 상태를 실시간으로 모니터링하고 관리할 수 있도록 설계되었습니다.
환경별 유연한 설정, 안정적인 클러스터 연결, 주기적인 데이터 동기화, 명확한 서비스 계층 분리 등은 시스템의 신뢰성과 유지보수성을 높이는 핵심 요소입니다.
향후 환경 변수 기반 설정, 네임스페이스 동적 관리, 인증 방식 다양화 등으로 확장성을 더욱 강화할 수 있습니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('a7867408-e2f3-4925-9e00-851d7ae71b5e', e'# GPU 대시보드 데이터 및 엔티티 관리

## Introduction

GPU 대시보드 시스템은 Kubernetes 환경 등에서 Pod(컨테이너) 및 관련 리소스의 상태, 사용자, 네임스페이스, GPU 장치 정보 등을 구조화하여 관리하고, 클라이언트 또는 내부 서비스에 일관된 데이터 전달을 보장하는 것을 목적으로 합니다. 본 문서는 주요 데이터 전달 객체(DTO)와 엔티티의 구조, 역할, 데이터 흐름, 그리고 각 구성요소의 책임을 명확히 설명합니다.

아래 Mermaid.js 아키텍처 다이어그램은 DTO, 엔티티, 그리고 이들이 위치할 수 있는 계층별 의존성 및 데이터 흐름을 시각적으로 나타냅니다.

**아키텍처 계층 및 데이터 흐름 개요**

```mermaid
graph TD
    subgraph "Presentation Layer"
        C1["API Controller"]
    end
    subgraph "DTO Layer"
        D1["DeletePodRequest"]
        D2["PodUpdateUserDto"]
        D3["PodInfoDto"]
        D4["PodResponseDto"]
        D5["DeletePodResponseDto"]
        D6["NamespaceDto"]
    end
    subgraph "Service Layer"
        S1["PodService"]
    end
    subgraph "Data Access Layer"
        R1["PodInfoEntity"]
    end

    C1 --> D1
    C1 --> D2
    C1 --> D6
    C1 --> S1
    S1 --> D3
    S1 --> D4
    S1 --> D5
    S1 --> R1
    R1 --> S1
```
*설명: 컨트롤러는 DTO를 통해 요청/응답 데이터를 주고받으며, 서비스 계층은 DTO와 엔티티를 변환·조작하여 비즈니스 로직을 수행합니다. 엔티티는 데이터베이스와 직접 연동됩니다.*

---

## 주요 구성 요소 및 데이터 구조

### 1. 데이터 전달 객체(DTO)

#### 1.1 DeletePodRequest

**역할:**
특정 네임스페이스 내의 Pod 삭제 요청 정보를 전달하는 DTO입니다.

**주요 필드 및 메서드:**

| 필드명      | 타입    | 설명                    |
|-------------|---------|-------------------------|
| namespace   | String  | 대상 네임스페이스       |
| podName     | String  | 삭제할 Pod 이름         |

**코드 스니펫:**
```java
public class DeletePodRequest {
    private String namespace;
    private String podName;

    public String getNamespace() { return namespace; }
    public void setNamespace(String namespace) { this.namespace = namespace; }
    public String getPodName() { return podName; }
    public void setPodName(String podName) { this.podName = podName; }
}
```

---

#### 1.2 PodUpdateUserDto

**역할:**
Pod와 관련된 사용자 정보를 전달하는 DTO입니다.

| 필드명      | 타입    | 설명                    |
|-------------|---------|-------------------------|
| namespace   | String  | 네임스페이스            |
| podname     | String  | Pod 이름                |
| username    | String  | 사용자 이름             |

**코드 스니펫:**
```java
public class PodUpdateUserDto {
    private String namespace;
    private String podname;
    private String username;

    public String getNamespace() { return namespace; }
    public void setNamespace(String namespace) { this.namespace = namespace; }
    public String getPodname() { return podname; }
    public void setPodname(String podname) { this.podname = podname; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}
```

---

#### 1.3 PodInfoDto

**역할:**
Pod의 상세 정보(상태, 가동 시간, GPU, 사용자 등)를 전달하는 DTO입니다.

| 필드명      | 타입    | 설명                    |
|-------------|---------|-------------------------|
| namespace   | String  | 네임스페이스            |
| podname     | String  | Pod 이름                |
| podstatus   | String  | Pod 상태                |
| poduptime   | String  | Pod 가동 시간           |
| gpuDevices  | String  | GPU 장치 정보           |
| username    | String  | 사용자 이름             |

**코드 스니펫:**
```java
public class PodInfoDto {
    private String namespace;
    private String podname;
    private String podstatus;
    private String poduptime;
    private String gpuDevices;
    private String username;

    public PodInfoDto(String namespace, String podname, String podstatus, String poduptime, String gpuDevices, String username) {
        this.namespace = namespace;
        this.podname = podname;
        this.podstatus = podstatus;
        this.poduptime = poduptime;
        this.gpuDevices = gpuDevices;
        this.username = username;
    }

    public String getNamespace() { return namespace; }
    public String getPodname() { return podname; }
    public String getPodstatus() { return podstatus; }
    public String getGpuDevices() { return gpuDevices; }
    public String getUsername() { return username; }
    public String getPoduptime() { return poduptime; }
}
```

---

#### 1.4 PodResponseDto

**역할:**
여러 PodInfoDto 객체를 리스트로 묶어 응답하는 DTO입니다.

| 필드명      | 타입                  | 설명                  |
|-------------|-----------------------|-----------------------|
| result      | List<PodInfoDto>      | Pod 정보 리스트       |

**코드 스니펫:**
```java
public class PodResponseDto {
    private List<PodInfoDto> result;

    public PodResponseDto(List<PodInfoDto> result) {
        this.result = result;
    }

    public List<PodInfoDto> getResult() { return result; }
}
```

---

#### 1.5 DeletePodResponseDto

**역할:**
Pod 삭제 요청에 대한 결과 상태를 전달하는 DTO입니다.

| 필드명      | 타입    | 설명                    |
|-------------|---------|-------------------------|
| status      | String  | 삭제 결과 상태          |

**코드 스니펫:**
```java
public class DeletePodResponseDto {
    private String status;

    public DeletePodResponseDto(String status) {
        this.status = status;
    }

    public String getStatus() { return status; }
}
```

---

#### 1.6 NamespaceDto

**역할:**
네임스페이스 정보를 전달하는 DTO입니다.

| 필드명      | 타입    | 설명                    |
|-------------|---------|-------------------------|
| namespace   | String  | 네임스페이스            |

**코드 스니펫:**
```java
public class NamespaceDto {
    private String namespace;

    public String getNamespace() { return namespace; }
    public void setNamespace(String namespace) { this.namespace = namespace; }
}
```

---

### 2. 엔티티

#### 2.1 PodInfoEntity

**역할:**
데이터베이스의 gpu_dashboard 테이블과 매핑되는 Pod 정보 엔티티입니다.

| 필드명         | 타입             | 설명                       |
|----------------|------------------|----------------------------|
| id             | Long             | PK, 자동 증가              |
| username       | String           | 사용자 이름                |
| namespace      | String           | 네임스페이스               |
| podName        | String           | Pod 이름                   |
| podStatus      | String           | Pod 상태                   |
| gpuDevices     | String           | GPU 장치 정보              |
| podUptime      | String           | Pod 가동 시간              |
| startDateTime  | LocalDateTime    | Pod 시작 시각              |

**코드 스니펫:**
```java
@Entity
@Table(name = "gpu_dashboard")
public class PodInfoEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String username;
    private String namespace;
    private String podName;
    private String podStatus;
    private String gpuDevices;
    private String podUptime;
    private LocalDateTime startDateTime;

    // Getter/Setter 생략
}
```

---

## 데이터 흐름 및 아키텍처 관계

아래 다이어그램은 주요 DTO와 엔티티가 각 계층에서 어떻게 상호작용하는지, 그리고 데이터가 어떻게 흐르는지 보여줍니다.

```mermaid
graph TD
    subgraph "Controller Layer"
        Controller["API Controller"]
    end
    subgraph "DTO Layer"
        DeletePodRequest["DeletePodRequest"]
        PodUpdateUserDto["PodUpdateUserDto"]
        NamespaceDto["NamespaceDto"]
        PodInfoDto["PodInfoDto"]
        PodResponseDto["PodResponseDto"]
        DeletePodResponseDto["DeletePodResponseDto"]
    end
    subgraph "Service Layer"
        PodService["PodService"]
    end
    subgraph "Data Access Layer"
        PodInfoEntity["PodInfoEntity"]
    end

    Controller --> DeletePodRequest
    Controller --> PodUpdateUserDto
    Controller --> NamespaceDto
    Controller --> PodService
    PodService --> PodInfoDto
    PodService --> PodResponseDto
    PodService --> DeletePodResponseDto
    PodService --> PodInfoEntity
    PodInfoEntity --> PodService
```
*설명: 컨트롤러는 요청 DTO를 받아 서비스에 전달하고, 서비스는 엔티티와 DTO를 변환하여 비즈니스 로직을 수행합니다. 응답 DTO는 컨트롤러를 통해 클라이언트에 반환됩니다.*

---

## 데이터 모델 상세

### PodInfoEntity 필드 상세

| 필드명         | 타입             | 제약조건/설명           |
|----------------|------------------|------------------------|
| id             | Long             | PK, 자동 증가          |
| username       | String           | 사용자 이름            |
| namespace      | String           | 네임스페이스           |
| podName        | String           | Pod 이름               |
| podStatus      | String           | Pod 상태               |
| gpuDevices     | String           | GPU 장치 정보          |
| podUptime      | String           | Pod 가동 시간          |
| startDateTime  | LocalDateTime    | Pod 시작 시각          |

---

## API 요청/응답 예시

### Pod 삭제 요청

| 파라미터명 | 타입   | 설명           |
|------------|--------|----------------|
| namespace  | String | 네임스페이스   |
| podName    | String | 삭제할 Pod 이름|

**요청 DTO 예시**
```json
{
  "namespace": "default",
  "podName": "gpu-pod-01"
}
```

**응답 DTO 예시**
```json
{
  "status": "SUCCESS"
}
```

---

## 결론

본 문서에서 설명한 DTO 및 엔티티 구조는 GPU 대시보드 시스템의 데이터 일관성, 유지보수성, 확장성을 보장하는 핵심 기반입니다. 각 클래스는 명확한 책임과 역할을 가지고 있으며, 계층 간 데이터 전달 및 변환을 통해 시스템의 견고함을 높입니다. 향후 유효성 검증, 불변성, 확장성 등 추가 개선을 통해 더욱 견고한 시스템으로 발전시킬 수 있습니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('3d9dda2d-4151-4111-8fce-b2e1a41adaf3', e'# GPU 대시보드 데이터 저장소

## 소개

GPU 대시보드 데이터 저장소는 Kubernetes 등 컨테이너 오케스트레이션 환경에서 Pod(컨테이너 그룹)의 상태, 위치, GPU 장치 정보 등 핵심 데이터를 효율적으로 저장하고 조회하기 위한 시스템의 핵심 데이터 계층입니다.
이 저장소는 Pod의 네임스페이스별 목록 조회, 특정 Pod 상세 조회 등 다양한 운영 및 모니터링 시나리오에서 신뢰성 있고 일관된 데이터 제공을 목표로 설계되었습니다.

아래 아키텍처 다이어그램은 전체 시스템의 주요 계층(도메인, 데이터 액세스, 비즈니스, 프레젠테이션)과 그 흐름을 시각적으로 보여줍니다.

**아키텍처 계층 및 의존성 흐름**

```mermaid
graph TD
    subgraph "Presentation Layer"
        Controller["PodInfoController"]
    end
    subgraph "Service Layer"
        Service["PodInfoService"]
    end
    subgraph "Data Access Layer"
        Repository["PodInfoRepository"]
    end
    subgraph "Domain Layer"
        Entity["PodInfoEntity"]
    end
    Controller --> Service
    Service --> Repository
    Repository --> Entity
```
*위 다이어그램은 Controller → Service → Repository → Entity로 이어지는 계층적 호출 구조를 나타냅니다.*

---

## 주요 구성 요소 및 아키텍처

### 데이터 모델: PodInfoEntity

#### 역할 및 구조

- **PodInfoEntity**는 데이터베이스 테이블(`gpu_dashboard`)의 각 행(row)을 표현하는 도메인 엔티티입니다.
- Pod의 식별자, 사용자, 네임스페이스, 이름, 상태, GPU 장치 정보, 가동 시간, 시작 시각 등 핵심 정보를 보관합니다.
- 각 필드는 getter/setter 메서드를 통해 안전하게 접근 및 수정할 수 있습니다.

#### 주요 필드 및 설명

| 필드명           | 타입              | 제약조건/설명            |
|------------------|-------------------|--------------------------|
| id               | Long              | PK, 자동 생성            |
| username         | String            | 사용자 이름              |
| namespace        | String            | Pod가 속한 네임스페이스  |
| podName          | String            | Pod 이름                 |
| podStatus        | String            | Pod 상태                 |
| gpuDevices       | String            | GPU 장치 정보            |
| podUptime        | String            | Pod 가동 시간            |
| startDateTime    | LocalDateTime     | Pod 시작 시각            |

#### 코드 스니펫

```java
@Entity
@Table(name = "gpu_dashboard")
public class PodInfoEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String username;
    private String namespace;
    private String podName;
    private String podStatus;
    private String gpuDevices;
    private String podUptime;
    private LocalDateTime startDateTime;

    // Getter/Setter 생략
}
```

#### 주요 메서드

| 메서드명            | 반환 타입      | 설명                         |
|---------------------|---------------|------------------------------|
| getId/setId         | Long/void     | 식별자 접근/설정             |
| getUsername/setUsername | String/void| 사용자 이름 접근/설정        |
| getNamespace/setNamespace | String/void | 네임스페이스 접근/설정   |
| getPodName/setPodName | String/void | Pod 이름 접근/설정           |
| getPodStatus/setPodStatus | String/void | Pod 상태 접근/설정      |
| getGpuDevices/setGpuDevices | String/void | GPU 정보 접근/설정      |
| getPodUptime/setPodUptime | String/void | 가동 시간 접근/설정      |
| getStartDateTime/setStartDateTime | LocalDateTime/void | 시작 시각 접근/설정 |

---

### 데이터 액세스 계층: PodInfoRepository

#### 역할 및 구조

- **PodInfoRepository**는 PodInfoEntity에 대한 데이터베이스 접근을 담당하는 JPA 리포지토리 인터페이스입니다.
- 네임스페이스별 Pod 목록 조회, 네임스페이스+Pod 이름으로 특정 Pod 상세 조회 기능을 제공합니다.

#### 주요 메서드

| 메서드명                           | 파라미터                  | 반환 타입                  | 설명                                 |
|-------------------------------------|---------------------------|---------------------------|--------------------------------------|
| findByNamespace                     | String namespace          | List<PodInfoEntity>       | 네임스페이스별 Pod 목록 조회         |
| findByNamespaceAndPodName           | String namespace, String podName | Optional<PodInfoEntity> | 네임스페이스+Pod 이름으로 Pod 조회   |

#### 코드 스니펫

```java
public interface PodInfoRepository extends JpaRepository<PodInfoEntity, Long> {
    List<PodInfoEntity> findByNamespace(String namespace);
    Optional<PodInfoEntity> findByNamespaceAndPodName(String namespace, String podName);
}
```

#### 데이터 흐름

- 서비스 계층에서 PodInfoRepository의 메서드를 호출하여 Pod 정보를 조회합니다.
- 반환값은 PodInfoEntity 객체(또는 리스트/Optional)로, 상위 계층에서 비즈니스 로직에 활용됩니다.

---

### 데이터 흐름 및 시퀀스

아래 시퀀스 다이어그램은 네임스페이스별 Pod 목록을 조회하는 전형적인 흐름을 보여줍니다.

```mermaid
sequenceDiagram
    participant Controller as PodInfoController
    participant Service as PodInfoService
    participant Repository as PodInfoRepository
    participant Entity as PodInfoEntity

    Controller->>+Service: findPodsByNamespace(namespace)
    Service->>+Repository: findByNamespace(namespace)
    Repository-->>-Service: List<PodInfoEntity>
    Service-->>-Controller: List<PodInfoEntity>
    Note over Controller,Service: Controller는 결과를 클라이언트에 반환
```

---

## 데이터 모델 상세

아래 표는 PodInfoEntity의 데이터베이스 스키마와 각 필드의 역할을 요약합니다.

| 컬럼명         | 타입           | 설명                |
|----------------|---------------|---------------------|
| id             | Long          | PK, 자동 증가       |
| username       | String        | 사용자 이름         |
| namespace      | String        | 네임스페이스        |
| podName        | String        | Pod 이름            |
| podStatus      | String        | Pod 상태            |
| gpuDevices     | String        | GPU 장치 정보       |
| podUptime      | String        | Pod 가동 시간       |
| startDateTime  | LocalDateTime | Pod 시작 시각       |

---

## 주요 기능 요약

| 기능명                        | 설명                                                         |
|-------------------------------|--------------------------------------------------------------|
| 네임스페이스별 Pod 목록 조회   | 특정 네임스페이스에 속한 모든 Pod 정보를 리스트로 반환        |
| 특정 Pod 상세 조회            | 네임스페이스와 Pod 이름으로 특정 Pod의 상세 정보를 반환       |
| GPU 장치 정보 조회            | PodInfoEntity의 getGpuDevices()로 GPU 정보 문자열 반환        |

---

## 설정 및 확장성

- **확장성**: 필터 조건 추가, 페이징, 정렬, 캐시, 외부 API 연동 등 다양한 확장 가능성이 내포되어 있습니다.
- **데이터 무결성**: Optional 반환, 캡슐화된 엔티티 구조로 null/예외 안전성을 높였습니다.
- **유지보수성**: 계층 분리, 명확한 책임 분담으로 코드 유지보수 및 확장에 용이합니다.

---

## 결론

GPU 대시보드 데이터 저장소는 Pod의 상태, GPU 리소스, 가동 시간 등 핵심 정보를 신뢰성 있게 관리하는 시스템의 핵심 데이터 계층입니다.
PodInfoEntity와 PodInfoRepository를 중심으로 한 구조는 데이터의 일관성, 확장성, 유지보수성을 보장하며, Kubernetes 기반 환경에서 Pod 모니터링 및 관리의 기반을 제공합니다.
향후 다양한 조건 추가, 성능 최적화, 실시간 연동 등 요구사항 변화에도 유연하게 대응할 수 있는 설계 구조를 갖추고 있습니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('48353c08-4382-4f26-876d-a6e988e160cc', e'# GPU 대시보드 기능

## 소개

GPU 대시보드 기능은 Kubernetes 클러스터 내 Pod 및 GPU 자원 상태를 실시간으로 수집, 저장, 동기화, 관리하는 시스템의 핵심 기능 집합입니다. 본 기능은 클러스터의 Pod 상태와 데이터베이스(DB) 간의 일관성을 유지하며, GPU 환경 변수 및 사용자 정보를 포함한 상세 Pod 정보를 제공합니다. 주요 목적은 클러스터 모니터링, 자원 관리, 사용자 요청 처리 등 시스템의 핵심 비즈니스 로직을 안정적으로 지원하는 것입니다.

아래 다이어그램은 GPU 대시보드 기능의 전체 계층 구조와 의존성 흐름을 시각화한 것입니다.

**아키텍처 계층 구조 및 의존성 흐름**

```mermaid
graph TD
    subgraph "Presentation Layer"
        Controller["PodController"]
    end
    subgraph "Service Layer"
        PodService["PodService"]
    end
    subgraph "Data Access Layer"
        PodInfoRepository["PodInfoRepository"]
    end
    subgraph "Domain Layer"
        PodInfoEntity["PodInfoEntity"]
        PodInfoDto["PodInfoDto"]
        PodResponseDto["PodResponseDto"]
        DeletePodRequest["DeletePodRequest"]
        DeletePodResponseDto["DeletePodResponseDto"]
        PodUpdateUserDto["PodUpdateUserDto"]
        NamespaceDto["NamespaceDto"]
    end
    subgraph "Configuration Layer"
        CoreV1Api["CoreV1Api"]
    end

    Controller --> PodService
    PodService --> CoreV1Api
    PodService --> PodInfoRepository
    PodInfoRepository --> PodInfoEntity
    PodService --> PodInfoDto
    PodService --> PodResponseDto
    PodService --> DeletePodResponseDto
    PodService --> PodUpdateUserDto
    PodService --> NamespaceDto
```
*상위 계층에서 하위 계층으로의 호출 흐름을 나타냅니다. Controller는 Service를, Service는 Data Access 및 외부 API, Domain 객체를 활용합니다.*

---

## 주요 기능 및 구성 요소

### 1. Pod 목록 조회 및 동기화

#### 기능 설명

- Kubernetes API(CoreV1Api)에서 네임스페이스별 Pod 목록을 실시간으로 조회합니다.
- 데이터베이스(PodInfoRepository)와 비교하여 불일치 Pod 정보를 삭제하거나 갱신합니다.
- Pod의 상세 정보(상태, 가동 시간, GPU 장치, 사용자명 등)를 추출하여 DB에 저장하고, PodInfoDto로 응답합니다.

#### 관련 메서드 및 데이터 흐름

| 메서드명                       | 설명                                                         |
|-------------------------------|-------------------------------------------------------------|
| `listPods(String namespace)`   | K8s API에서 Pod 목록 수집, DB와 동기화, DTO 반환             |
| `savePodInfo(...)`             | Pod 정보 신규 저장 또는 갱신(내부)                            |

**주요 코드 스니펫**

```java
public PodResponseDto listPods(String namespace) throws Exception {
    V1PodList podList = coreV1Api.listNamespacedPod(
        namespace != null ? namespace.trim() : "",
        null, null, null, null, null, null, null, null, null, false
    );
    Set<String> currentPodNames = podList.getItems().stream()
        .map(pod -> pod.getMetadata().getName())
        .collect(Collectors.toSet());

    List<PodInfoEntity> dbPods = podInfoRepository.findByNamespace(namespace);
    for (PodInfoEntity dbPod : dbPods) {
        if (!currentPodNames.contains(dbPod.getPodName())) {
            podInfoRepository.delete(dbPod);
        }
    }

    List<PodInfoDto> podInfos = podList.getItems().stream()
        .map(pod -> {
            // ... Pod 정보 추출 및 가공 ...
            savePodInfo(namespace, podName, podPhase, poduptime, gpuDevices);
            return new PodInfoDto(namespace, podName, podPhase, poduptime, gpuDevices, username);
        })
        .collect(Collectors.toList());

    return new PodResponseDto(podInfos);
}
```

---

### 2. Pod 정보 DB 조회

#### 기능 설명

- 데이터베이스에서 네임스페이스별 Pod 목록을 조회합니다.
- PodInfoEntity를 PodInfoDto로 변환하여 응답합니다.

| 메서드명                       | 설명                              |
|-------------------------------|-----------------------------------|
| `getPodsFromDb(String ns)`     | DB에서 Pod 목록 조회, DTO 반환     |

---

### 3. Pod 삭제

#### 기능 설명

- 클러스터 및 데이터베이스에서 Pod를 삭제합니다.
- 삭제 결과를 DeletePodResponseDto로 반환합니다.

| 메서드명                                 | 설명                                 |
|------------------------------------------|--------------------------------------|
| `deletePod(String ns, String podName)`   | K8s 및 DB에서 Pod 삭제, 결과 반환    |

**주요 코드 스니펫**

```java
@PostMapping("/pods/delete")
public DeletePodResponseDto deletePod(@RequestBody DeletePodRequest request) {
    try {
        logger.debug("Pod 삭제 요청 - namespace: {}, podName: {}",
            request.getNamespace(), request.getPodName());
        return podService.deletePod(request.getNamespace(), request.getPodName());
    } catch (Exception e) {
        logger.error("Pod 삭제 중 오류 발생: ", e);
        return new DeletePodResponseDto("fail");
    }
}
```

---

### 4. Pod 사용자 정보 변경

#### 기능 설명

- Pod의 사용자 정보를 갱신합니다.
- 변경 결과를 PodResponseDto로 반환합니다.

| 메서드명                                 | 설명                                 |
|------------------------------------------|--------------------------------------|
| `updateUsername(ns, podName, username)`  | Pod 사용자 정보 갱신, 결과 반환      |

---

### 5. 데이터 흐름 및 API 시퀀스

**Pod 목록 동기화 및 조회 시퀀스**

```mermaid
sequenceDiagram
    participant Client
    participant Controller
    participant PodService
    participant CoreV1Api
    participant PodInfoRepository
    participant DB

    Client->>Controller: Pod 목록 요청
    Controller->>PodService: listPods(namespace)
    PodService->>+CoreV1Api: listNamespacedPod(namespace)
    CoreV1Api-->>-PodService: V1PodList 반환
    PodService->>+PodInfoRepository: findByNamespace(namespace)
    PodInfoRepository-->>-PodService: DB Pod 목록 반환
    PodService->>PodInfoRepository: 필요시 delete(dbPod)
    PodService->>PodInfoRepository: savePodInfo(...) (신규/갱신)
    PodService-->>Controller: PodResponseDto 반환
    Controller-->>Client: Pod 목록 응답
    Note over PodService,PodInfoRepository: Pod 상태 동기화 및 DB 정합성 유지
```
*클라이언트의 요청부터 쿠버네티스 API, DB 동기화, 응답까지의 전체 흐름을 나타냅니다.*

---

## 데이터 모델 및 DTO 구조

### PodInfoEntity

| 필드명         | 타입             | 제약/설명                |
|----------------|------------------|--------------------------|
| id             | Long             | PK, 자동 생성            |
| username       | String           | 사용자명                 |
| namespace      | String           | 네임스페이스             |
| podName        | String           | Pod 이름                 |
| podStatus      | String           | Pod 상태                 |
| gpuDevices     | String           | GPU 장치 정보            |
| podUptime      | String           | Pod 가동 시간            |
| startDateTime  | LocalDateTime    | Pod 시작 시각            |

### PodInfoDto

| 필드명      | 타입    | 설명                |
|-------------|---------|---------------------|
| namespace   | String  | 네임스페이스        |
| podname     | String  | Pod 이름            |
| podstatus   | String  | Pod 상태            |
| poduptime   | String  | Pod 가동 시간       |
| gpuDevices  | String  | GPU 장치 정보       |
| username    | String  | 사용자명            |

### PodResponseDto

```java
public class PodResponseDto {
    private List<PodInfoDto> result;
    public PodResponseDto(List<PodInfoDto> result) { this.result = result; }
    public List<PodInfoDto> getResult() { return result; }
}
```

### DeletePodRequest / DeletePodResponseDto

| 클래스명               | 필드/메서드            | 설명                       |
|-----------------------|------------------------|----------------------------|
| DeletePodRequest      | namespace, podName     | 삭제 대상 Pod 식별         |
| DeletePodResponseDto  | status                 | 삭제 결과("success"/"fail")|

### PodUpdateUserDto

| 필드명     | 타입    | 설명         |
|------------|---------|--------------|
| namespace  | String  | 네임스페이스 |
| podname    | String  | Pod 이름     |
| username   | String  | 사용자명     |

### NamespaceDto

| 필드명     | 타입    | 설명         |
|------------|---------|--------------|
| namespace  | String  | 네임스페이스 |

---

## API 엔드포인트 요약

| 엔드포인트                | HTTP | 요청 DTO           | 응답 DTO               | 설명                       |
|---------------------------|------|--------------------|------------------------|----------------------------|
| /pods                     | POST | NamespaceDto       | PodResponseDto         | 네임스페이스 내 Pod 목록 조회 및 DB 저장 |
| /pods/db                  | POST | NamespaceDto       | PodResponseDto         | DB에서 Pod 목록 조회       |
| /pods/delete              | POST | DeletePodRequest   | DeletePodResponseDto   | Pod 삭제                   |
| /pods/update/username     | POST | PodUpdateUserDto   | PodResponseDto         | Pod 사용자 이름 변경       |

---

## 설정 및 확장성

| 설정 항목           | 타입      | 기본값/설명                  |
|---------------------|-----------|------------------------------|
| CoreV1Api           | Bean      | 쿠버네티스 API 클라이언트    |
| PodInfoRepository   | Bean      | JPA 기반 DB 리포지토리       |
| TimeZone            | String    | "Asia/Seoul" (KST)           |

---

## 결론

GPU 대시보드 기능은 Kubernetes 클러스터의 Pod 및 GPU 자원 상태를 실시간으로 모니터링하고, 데이터베이스와의 정합성을 유지하는 핵심 기능입니다. 서비스 계층의 명확한 책임 분리, DTO/엔티티 구조화, 데이터 액세스 계층의 효율적 설계가 돋보이며, 클러스터 운영 및 자원 관리의 신뢰성과 효율성을 높이는 데 중요한 역할을 수행합니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('3fc8fa68-8d9e-4366-8a64-82639f49a82a', e'# GPU 대시보드 서비스

## 소개

GPU 대시보드 서비스는 쿠버네티스(Kubernetes) 클러스터 내의 Pod 및 GPU 자원 상태를 실시간으로 수집, 저장, 동기화, 관리하는 시스템입니다. 본 서비스는 클러스터의 Pod 상태와 데이터베이스(DB) 간의 일관성을 유지하며, GPU 환경 변수 및 사용자 정보를 포함한 상세 Pod 정보를 제공합니다. 주요 목적은 클러스터 모니터링, 자원 관리, 사용자 요청 처리 등 시스템의 핵심 비즈니스 로직을 안정적으로 지원하는 것입니다.

아래 다이어그램은 전체 시스템의 주요 계층(Controller, Service, Data Access, Domain, Configuration) 간 의존성 흐름을 나타냅니다.

**아키텍처 계층 구조 및 의존성 흐름**

```mermaid
graph TD
    subgraph "Presentation Layer"
        Controller["PodController"]
    end
    subgraph "Service Layer"
        PodService["PodService"]
    end
    subgraph "Data Access Layer"
        PodInfoRepository["PodInfoRepository"]
    end
    subgraph "Domain Layer"
        PodInfoEntity["PodInfoEntity"]
        PodInfoDto["PodInfoDto"]
        PodResponseDto["PodResponseDto"]
        DeletePodRequest["DeletePodRequest"]
        DeletePodResponseDto["DeletePodResponseDto"]
        PodUpdateUserDto["PodUpdateUserDto"]
        NamespaceDto["NamespaceDto"]
    end
    subgraph "Configuration Layer"
        CoreV1Api["CoreV1Api"]
    end

    Controller --> PodService
    PodService --> CoreV1Api
    PodService --> PodInfoRepository
    PodInfoRepository --> PodInfoEntity
    PodService --> PodInfoDto
    PodService --> PodResponseDto
    PodService --> DeletePodResponseDto
    PodService --> PodUpdateUserDto
    PodService --> NamespaceDto
```
*상위 계층에서 하위 계층으로의 호출 흐름을 나타냅니다. Controller는 Service를, Service는 Data Access 및 외부 API, Domain 객체를 활용합니다.*

---

## 주요 구성 요소 및 아키텍처

### 1. 서비스 계층: PodService

#### 역할 및 책임

- **PodService**는 GPU 및 Pod 관련 정보를 관리하는 핵심 서비스 계층입니다.
- 쿠버네티스 API(`CoreV1Api`)와 데이터베이스(`PodInfoRepository`)를 연동하여, 클러스터 상태와 DB 상태를 동기화합니다.
- Pod의 상세 정보 수집, 저장, 갱신, 삭제, 사용자 정보 업데이트 등 핵심 비즈니스 로직을 담당합니다.

#### 주요 메서드 및 데이터 흐름

| 메서드명                       | 설명                                                         |
|-------------------------------|-------------------------------------------------------------|
| `listPods(String namespace)`   | 쿠버네티스 API에서 Pod 목록 수집, DB와 동기화, DTO 반환       |
| `getPodsFromDb(String ns)`     | DB에서 Pod 목록 조회, DTO로 반환                              |
| `deletePod(String ns, String podName)` | 쿠버네티스 및 DB에서 Pod 삭제, 결과 DTO 반환         |
| `updatePodStatusInDb(ns, podName, status)` | DB 내 Pod 상태 갱신(내부)                        |
| `updateUsername(ns, podName, username)` | Pod의 사용자 정보 갱신, 결과 DTO 반환                |
| `savePodInfo(...)`             | Pod 정보 신규 저장 또는 갱신(내부)                            |

#### 코드 스니펫: Pod 목록 동기화 및 저장

```java
public PodResponseDto listPods(String namespace) throws Exception {
    V1PodList podList = coreV1Api.listNamespacedPod(
        namespace != null ? namespace.trim() : "",
        null, null, null, null, null, null, null, null, null, false
    );
    Set<String> currentPodNames = podList.getItems().stream()
        .map(pod -> pod.getMetadata().getName())
        .collect(Collectors.toSet());

    List<PodInfoEntity> dbPods = podInfoRepository.findByNamespace(namespace);
    for (PodInfoEntity dbPod : dbPods) {
        if (!currentPodNames.contains(dbPod.getPodName())) {
            podInfoRepository.delete(dbPod);
        }
    }

    List<PodInfoDto> podInfos = podList.getItems().stream()
        .map(pod -> {
            // ... Pod 정보 추출 및 가공 ...
            savePodInfo(namespace, podName, podPhase, poduptime, gpuDevices);
            return new PodInfoDto(namespace, podName, podPhase, poduptime, gpuDevices, username);
        })
        .collect(Collectors.toList());

    return new PodResponseDto(podInfos);
}
```

#### 데이터 흐름 요약

1. 쿠버네티스 API에서 Pod 목록 조회
2. DB와 비교하여 불일치 Pod 삭제
3. Pod 상세 정보 추출 및 DB 저장/갱신
4. Pod 정보 DTO 생성 및 반환

---

### 2. 데이터 액세스 계층: PodInfoRepository

#### 역할 및 책임

- Pod 정보를 데이터베이스에서 조회, 저장, 삭제하는 JPA 기반 리포지토리 인터페이스입니다.
- 네임스페이스별, Pod 이름별로 효율적인 조회를 지원합니다.

#### 주요 메서드

| 메서드명                                 | 반환 타입                        | 설명                                 |
|------------------------------------------|----------------------------------|--------------------------------------|
| `findByNamespace(String namespace)`      | `List<PodInfoEntity>`            | 네임스페이스별 Pod 목록 조회         |
| `findByNamespaceAndPodName(ns, podName)` | `Optional<PodInfoEntity>`        | 네임스페이스+Pod 이름으로 단일 조회  |

#### 코드 스니펫

```java
public interface PodInfoRepository extends JpaRepository<PodInfoEntity, Long> {
    List<PodInfoEntity> findByNamespace(String namespace);
    Optional<PodInfoEntity> findByNamespaceAndPodName(String namespace, String podName);
}
```

---

### 3. 도메인/DTO 계층

#### PodInfoEntity

- DB 테이블(`gpu_dashboard`)의 한 행(row)을 표현하는 엔티티 클래스입니다.
- Pod의 네임스페이스, 이름, 상태, GPU 장치, 가동 시간, 시작 시간, 사용자명 등 핵심 정보를 보유합니다.

| 필드명         | 타입             | 제약/설명                |
|----------------|------------------|--------------------------|
| id             | Long             | PK, 자동 생성            |
| username       | String           | 사용자명                 |
| namespace      | String           | 네임스페이스             |
| podName        | String           | Pod 이름                 |
| podStatus      | String           | Pod 상태                 |
| gpuDevices     | String           | GPU 장치 정보            |
| podUptime      | String           | Pod 가동 시간            |
| startDateTime  | LocalDateTime    | Pod 시작 시각            |

#### PodInfoDto

- Pod의 핵심 정보를 응답 또는 내부 전달용으로 구조화한 DTO입니다.

| 필드명      | 타입    | 설명                |
|-------------|---------|---------------------|
| namespace   | String  | 네임스페이스        |
| podname     | String  | Pod 이름            |
| podstatus   | String  | Pod 상태            |
| poduptime   | String  | Pod 가동 시간       |
| gpuDevices  | String  | GPU 장치 정보       |
| username    | String  | 사용자명            |

#### PodResponseDto

- 여러 PodInfoDto 객체를 리스트로 묶어 응답하는 DTO입니다.

```java
public class PodResponseDto {
    private List<PodInfoDto> result;
    public PodResponseDto(List<PodInfoDto> result) { this.result = result; }
    public List<PodInfoDto> getResult() { return result; }
}
```

#### DeletePodRequest / DeletePodResponseDto

- Pod 삭제 요청 및 결과 응답을 위한 DTO입니다.

| 클래스명               | 필드/메서드            | 설명                       |
|-----------------------|------------------------|----------------------------|
| DeletePodRequest      | namespace, podName     | 삭제 대상 Pod 식별         |
| DeletePodResponseDto  | status                 | 삭제 결과("success"/"fail")|

#### PodUpdateUserDto

- Pod의 사용자 정보 갱신 요청을 위한 DTO입니다.

| 필드명     | 타입    | 설명         |
|------------|---------|--------------|
| namespace  | String  | 네임스페이스 |
| podname    | String  | Pod 이름     |
| username   | String  | 사용자명     |

#### NamespaceDto

- 네임스페이스 정보를 전달하는 단순 DTO입니다.

---

### 4. 데이터 흐름 및 API 시퀀스

**Pod 목록 동기화 및 조회 시퀀스**

```mermaid
sequenceDiagram
    participant Client
    participant Controller
    participant PodService
    participant CoreV1Api
    participant PodInfoRepository
    participant DB

    Client->>Controller: Pod 목록 요청
    Controller->>PodService: listPods(namespace)
    PodService->>+CoreV1Api: listNamespacedPod(namespace)
    CoreV1Api-->>-PodService: V1PodList 반환
    PodService->>+PodInfoRepository: findByNamespace(namespace)
    PodInfoRepository-->>-PodService: DB Pod 목록 반환
    PodService->>PodInfoRepository: 필요시 delete(dbPod)
    PodService->>PodInfoRepository: savePodInfo(...) (신규/갱신)
    PodService-->>Controller: PodResponseDto 반환
    Controller-->>Client: Pod 목록 응답
    Note over PodService,PodInfoRepository: Pod 상태 동기화 및 DB 정합성 유지
```
*클라이언트의 요청부터 쿠버네티스 API, DB 동기화, 응답까지의 전체 흐름을 나타냅니다.*

---

## API 엔드포인트 및 데이터 구조 요약

| 엔드포인트/기능           | 요청 DTO/파라미터         | 응답 DTO/타입           | 설명                        |
|--------------------------|--------------------------|-------------------------|-----------------------------|
| Pod 목록 조회            | namespace (String)       | PodResponseDto          | 네임스페이스별 Pod 목록 조회|
| Pod DB 조회              | namespace (String)       | PodResponseDto          | DB 기준 Pod 목록 조회       |
| Pod 삭제                 | DeletePodRequest         | DeletePodResponseDto    | Pod 삭제 요청 및 결과 반환  |
| Pod 사용자명 갱신        | PodUpdateUserDto         | PodResponseDto          | Pod 사용자 정보 변경        |

---

## 설정 및 확장성

| 설정 항목           | 타입      | 기본값/설명                  |
|---------------------|-----------|------------------------------|
| CoreV1Api           | Bean      | 쿠버네티스 API 클라이언트    |
| PodInfoRepository   | Bean      | JPA 기반 DB 리포지토리       |
| TimeZone            | String    | "Asia/Seoul" (KST)           |

---

## 결론

GPU 대시보드 서비스는 쿠버네티스 클러스터의 Pod 및 GPU 자원 상태를 실시간으로 모니터링하고, 데이터베이스와의 정합성을 유지하는 핵심 서비스입니다. 서비스 계층의 명확한 책임 분리, DTO/엔티티 구조화, 데이터 액세스 계층의 효율적 설계가 돋보이며, 향후 성능 최적화, 기능 확장, 보안 강화 등 다양한 발전 방향을 내포하고 있습니다. 본 시스템은 클러스터 운영 및 자원 관리의 신뢰성과 효율성을 높이는 데 중요한 역할을 수행합니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('61f44b7d-40e6-4294-b9ef-762a9f9b56fe', e'# GPU 대시보드 컨트롤러

## 소개

GPU 대시보드 컨트롤러는 Kubernetes 클러스터 내 Pod의 상태를 실시간으로 모니터링하고, 데이터베이스와 동기화하며, Pod의 조회·삭제·사용자 정보 변경 등 다양한 관리 기능을 REST API로 제공합니다. 본 시스템은 Spring Framework 기반의 계층형 아키텍처로 설계되어, 클라이언트 요청을 안전하게 처리하고, 클러스터와 데이터베이스의 상태 일관성을 유지하는 데 중점을 둡니다.

아래 다이어그램은 전체 시스템의 계층별 의존성 흐름을 시각화한 것입니다.

**아키텍처 계층 및 의존성 흐름**

```mermaid
graph TD
    subgraph "Presentation Layer"
        PodController["PodController"]
    end
    subgraph "Business(Service) Layer"
        PodService["PodService"]
    end
    subgraph "Data Access Layer"
        PodInfoRepository["PodInfoRepository"]
    end
    subgraph "External API"
        CoreV1Api["CoreV1Api (K8s)"]
    end
    PodController --> PodService
    PodService --> PodInfoRepository
    PodService --> CoreV1Api
```
*PodController는 클라이언트 요청을 받아 PodService에 위임하며, PodService는 데이터베이스(PodInfoRepository)와 Kubernetes API(CoreV1Api) 모두와 직접 상호작용합니다.*

---

## 주요 구성 요소 및 아키텍처

### 1. Controller Layer

#### 1.1 PodController

- **역할**: 클라이언트로부터의 REST API 요청을 받아, Pod 관련 비즈니스 로직을 PodService에 위임하고, 결과를 DTO 형태로 반환합니다.
- **주요 엔드포인트**:
  - `/pods` : 네임스페이스 내 Pod 목록 조회 및 DB 저장
  - `/pods/db` : DB에서 Pod 목록 조회
  - `/pods/delete` : Pod 삭제
  - `/pods/update/username` : Pod 사용자 이름 변경

**주요 메서드 및 데이터 흐름**

| 메서드명                        | HTTP/엔드포인트         | 요청 DTO                | 응답 DTO                   | 설명                                 |
|----------------------------------|-------------------------|-------------------------|----------------------------|--------------------------------------|
| getPods                         | POST `/pods`            | NamespaceDto            | PodResponseDto             | 네임스페이스 내 Pod 목록 조회 및 DB 저장 |
| getPodsFromDb                   | POST `/pods/db`         | NamespaceDto            | PodResponseDto             | DB에서 Pod 목록 조회                 |
| deletePod                       | POST `/pods/delete`     | DeletePodRequest        | DeletePodResponseDto       | Pod 삭제                             |
| updatePod                       | POST `/pods/update/username` | PodUpdateUserDto   | PodResponseDto             | Pod 사용자 이름 변경                 |

**예시 코드 스니펫**

```java
@PostMapping("/pods/delete")
public DeletePodResponseDto deletePod(@RequestBody DeletePodRequest request) {
    try {
        logger.debug("Pod 삭제 요청 - namespace: {}, podName: {}",
            request.getNamespace(), request.getPodName());
        return podService.deletePod(request.getNamespace(), request.getPodName());
    } catch (Exception e) {
        logger.error("Pod 삭제 중 오류 발생: ", e);
        return new DeletePodResponseDto("fail");
    }
}
```

---

### 2. Service Layer

#### 2.1 PodService

- **역할**: Pod의 상태 조회, 동기화, 삭제, 사용자 정보 변경 등 핵심 비즈니스 로직을 수행합니다.
- **주요 기능**:
  - Kubernetes API를 통한 실시간 Pod 목록 조회 및 DB 동기화
  - DB에서 Pod 정보 조회
  - Pod 삭제 및 상태 갱신
  - Pod 사용자 이름 업데이트

**주요 메서드**

| 메서드명               | 파라미터                                    | 반환 타입                | 설명                                    |
|------------------------|---------------------------------------------|-------------------------|-----------------------------------------|
| listPods               | String namespace                            | PodResponseDto          | K8s API로 Pod 목록 조회 및 DB 동기화    |
| getPodsFromDb          | String namespace                            | PodResponseDto          | DB에서 Pod 목록 조회                    |
| deletePod              | String namespace, String podName            | DeletePodResponseDto    | Pod 삭제 및 DB 상태 갱신                |
| updateUsername         | String namespace, String podName, String username | PodResponseDto   | Pod 사용자 이름 변경                   |

**핵심 데이터 흐름**

```mermaid
graph TD
    subgraph "Controller Layer"
        PodController
    end
    subgraph "Service Layer"
        PodService
    end
    subgraph "Data Access Layer"
        PodInfoRepository
    end
    subgraph "External API"
        CoreV1Api
    end
    PodController --> PodService
    PodService --> PodInfoRepository
    PodService --> CoreV1Api
```
*PodService는 PodInfoRepository(데이터베이스)와 CoreV1Api(Kubernetes API) 모두와 직접 상호작용합니다.*

**주요 코드 스니펫**

```java
public PodResponseDto listPods(String namespace) throws Exception {
    V1PodList podList = coreV1Api.listNamespacedPod(namespace, ...);
    // 현재 시간, Pod 이름, 상태, GPU 정보 등 추출
    // DB와 동기화
    return new PodResponseDto(podInfos);
}
```

---

### 3. Data Transfer Objects (DTO)

#### 3.1 주요 DTO 및 데이터 구조

| DTO 클래스명            | 주요 필드/메서드                      | 설명                                         |
|------------------------|---------------------------------------|----------------------------------------------|
| NamespaceDto           | namespace                             | 네임스페이스 정보 전달                       |
| DeletePodRequest       | namespace, podName                    | Pod 삭제 요청 정보                           |
| PodUpdateUserDto       | namespace, podname, username          | Pod 사용자 이름 변경 요청 정보               |
| PodInfoDto             | namespace, podname, podstatus, poduptime, gpuDevices, username | Pod 상세 정보 |
| PodResponseDto         | List<PodInfoDto> result               | Pod 목록 응답                                |
| DeletePodResponseDto   | status                                | Pod 삭제 결과 응답                           |

**PodInfoDto 필드 상세**

| 필드명      | 타입    | 설명                |
|-------------|---------|---------------------|
| namespace   | String  | 네임스페이스        |
| podname     | String  | Pod 이름            |
| podstatus   | String  | Pod 상태            |
| poduptime   | String  | Pod 가동 시간        |
| gpuDevices  | String  | GPU 장치 정보        |
| username    | String  | 사용자 이름          |

**예시 DTO 코드**

```java
public class PodInfoDto {
    private String namespace;
    private String podname;
    private String podstatus;
    private String poduptime;
    private String gpuDevices;
    private String username;

    public PodInfoDto(String namespace, String podname, String podstatus, String poduptime, String gpuDevices, String username) {
        this.namespace = namespace;
        this.podname = podname;
        this.podstatus = podstatus;
        this.poduptime = poduptime;
        this.gpuDevices = gpuDevices;
        this.username = username;
    }
    // getter 생략
}
```

---

### 4. 데이터 흐름 및 API 시퀀스

아래 시퀀스 다이어그램은 Pod 삭제 요청의 전체 흐름을 보여줍니다.

```mermaid
sequenceDiagram
    participant Client as 클라이언트
    participant Controller as PodController
    participant Service as PodService
    participant K8sAPI as CoreV1Api
    participant Repo as PodInfoRepository

    Client->>+Controller: /pods/delete (DeletePodRequest)
    Controller->>+Service: deletePod(namespace, podName)
    Service->>+K8sAPI: deleteNamespacedPod()
    K8sAPI-->>-Service: 삭제 결과
    Service->>+Repo: updatePodStatusInDb()
    Repo-->>-Service: 저장 결과
    Service-->>-Controller: DeletePodResponseDto
    Controller-->>-Client: DeletePodResponseDto
    Note over Client,Controller: 실패 시 "fail" 반환
```

---

## API 엔드포인트 요약

| 엔드포인트                | HTTP | 요청 DTO           | 응답 DTO               | 설명                       |
|---------------------------|------|--------------------|------------------------|----------------------------|
| /pods                     | POST | NamespaceDto       | PodResponseDto         | 네임스페이스 내 Pod 목록 조회 및 DB 저장 |
| /pods/db                  | POST | NamespaceDto       | PodResponseDto         | DB에서 Pod 목록 조회       |
| /pods/delete              | POST | DeletePodRequest   | DeletePodResponseDto   | Pod 삭제                   |
| /pods/update/username     | POST | PodUpdateUserDto   | PodResponseDto         | Pod 사용자 이름 변경       |

---

## 설정 및 확장성

- **설정 항목**: 코드 상에서 직접적으로 노출된 설정 옵션은 없으나, CoreV1Api 및 데이터베이스 연결 설정이 필요합니다.
- **확장성**: 페이징, 필터링, 상세 오류 메시지, 인증/권한 검증, 비동기 처리 등 다양한 확장 가능성이 내포되어 있습니다.

---

## 결론

GPU 대시보드 컨트롤러는 Kubernetes 클러스터와 데이터베이스를 연동하여 Pod 상태를 실시간으로 관리하고, REST API를 통해 Pod의 조회, 삭제, 사용자 정보 변경 등 다양한 기능을 제공합니다. 계층별 책임 분리와 DTO 기반 설계로 유지보수성과 확장성이 뛰어나며, 클러스터 관리 및 모니터링 시스템의 핵심 인터페이스 역할을 수행합니다. 향후 보안, 성능, 사용자 경험 개선을 위한 확장도 용이한 구조입니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('37257df8-bb99-4e03-a80b-1a0a53e2312e', e'# 쿠버네티스 연동

## Introduction

쿠버네티스 연동 시스템은 쿠버네티스 클러스터 환경에서 오픈API 클라이언트 모델 및 API, 그리고 클러스터 리소스 제어를 위한 클라이언트 유틸리티를 제공합니다. 본 시스템의 목적은 오픈API 스펙 기반의 모델 관리와 쿠버네티스 리소스의 프로그래밍적 제어를 계층적으로 구조화하여, 효율적이고 확장 가능한 연동을 실현하는 것입니다.

아래 아키텍처 다이어그램은 전체 시스템의 주요 계층과 의존성 흐름을 시각화한 것입니다.

```mermaid
graph TD
    subgraph "Controller Layer"
        OpenAPIController["OpenAPIController"]
        K8sClientController["K8sClientController"]
    end
    subgraph "Service Layer"
        OpenAPIService["OpenAPIService"]
        K8sClientService["K8sClientService"]
    end
    subgraph "Data Access Layer"
        OpenAPIRepository["OpenAPIRepository"]
        K8sApiClient["K8sApiClient"]
        K8sConfigLoader["K8sConfigLoader"]
    end
    subgraph "Domain Layer"
        OpenAPIModel["OpenAPIModel"]
    end
    subgraph "Configuration Layer"
        OpenAPIConfig["OpenAPIConfig"]
    end
    OpenAPIController --> OpenAPIService
    K8sClientController --> K8sClientService
    OpenAPIService --> OpenAPIRepository
    OpenAPIService --> OpenAPIConfig
    OpenAPIRepository --> OpenAPIModel
    K8sClientService --> K8sApiClient
    K8sClientService --> K8sConfigLoader
```

*설명: 오픈API 및 쿠버네티스 클라이언트 유틸리티가 각각 Controller, Service, Data Access, Domain, Configuration 계층으로 분리되어 있으며, 각 계층은 역할에 따라 상호작용합니다.*

---

## 시스템 구성 요소 및 아키텍처

### Controller Layer

#### 주요 역할
- 외부 클라이언트의 요청을 수신하고, Service Layer로 위임합니다.

| 구성 요소               | 설명                                 |
|------------------------|--------------------------------------|
| OpenAPIController      | 오픈API 모델 및 API 요청 처리         |
| K8sClientController    | 쿠버네티스 리소스 제어 요청 처리      |

---

### Service Layer

#### 주요 역할
- 비즈니스 로직을 수행하고, Data Access 및 설정 계층과 상호작용합니다.

| 구성 요소             | 설명                                   |
|----------------------|----------------------------------------|
| OpenAPIService       | 오픈API 모델 및 API 비즈니스 로직 처리  |
| K8sClientService     | 쿠버네티스 리소스 관리 로직 수행        |

---

### Data Access Layer

#### 주요 역할
- 데이터 저장소, 쿠버네티스 API 서버, 설정 파일 등 외부 자원과 직접 통신합니다.

| 구성 요소           | 설명                                       |
|--------------------|--------------------------------------------|
| OpenAPIRepository  | 오픈API 모델 데이터 저장소 접근 및 조작      |
| K8sApiClient       | 쿠버네티스 API 서버와 직접 통신             |
| K8sConfigLoader    | 쿠버네티스 클러스터 접속 설정 로드 및 인증  |

---

### Domain Layer

#### 주요 역할
- 오픈API 클라이언트 모델의 데이터 구조를 정의합니다.

| 모델명           | 설명                             |
|------------------|----------------------------------|
| OpenAPIModel     | 오픈API 요청/응답 데이터 모델    |

---

### Configuration Layer

#### 주요 역할
- 시스템 및 API 설정 정보를 관리합니다.

| 구성 요소         | 설명                             |
|-------------------|----------------------------------|
| OpenAPIConfig     | 오픈API 및 시스템 설정 관리       |

---

## 데이터 흐름 및 로직

아래 다이어그램은 오픈API 및 쿠버네티스 클라이언트 유틸리티의 요청 처리 플로우를 보여줍니다.

```mermaid
graph TD
    subgraph "Controller Layer"
        OpenAPIController["OpenAPIController"]
        K8sClientController["K8sClientController"]
    end
    subgraph "Service Layer"
        OpenAPIService["OpenAPIService"]
        K8sClientService["K8sClientService"]
    end
    subgraph "Data Access Layer"
        OpenAPIRepository["OpenAPIRepository"]
        K8sApiClient["K8sApiClient"]
        K8sConfigLoader["K8sConfigLoader"]
    end
    subgraph "Domain Layer"
        OpenAPIModel["OpenAPIModel"]
    end
    subgraph "Configuration Layer"
        OpenAPIConfig["OpenAPIConfig"]
    end
    OpenAPIController --> OpenAPIService
    OpenAPIService --> OpenAPIRepository
    OpenAPIService --> OpenAPIConfig
    OpenAPIRepository --> OpenAPIModel
    K8sClientController --> K8sClientService
    K8sClientService --> K8sApiClient
    K8sClientService --> K8sConfigLoader
```

*설명: 각 Controller가 요청을 받아 Service로 전달하며, Service는 필요한 Data Access 및 설정 계층과 상호작용합니다.*

---

## 오픈API 클라이언트 모델 및 API

### API 엔드포인트

| 엔드포인트           | 메서드 | 파라미터 | 설명                     |
|----------------------|--------|----------|--------------------------|
| /openapi/models      | GET    | 없음     | 오픈API 모델 목록 조회   |
| /openapi/model/{id}  | GET    | id       | 특정 모델 상세 조회      |
| /openapi/model       | POST   | body     | 모델 생성                |
| /openapi/model/{id}  | PUT    | id, body | 모델 수정                |
| /openapi/model/{id}  | DELETE | id       | 모델 삭제                |

---

### 데이터 모델 필드

| 필드명     | 타입    | 제약 조건 | 설명                |
|------------|---------|-----------|---------------------|
| id         | string  | 필수      | 모델 식별자         |
| name       | string  | 필수      | 모델 이름           |
| spec       | object  | 필수      | 오픈API 스펙 정보   |
| createdAt  | string  | 선택      | 생성 일시           |
| updatedAt  | string  | 선택      | 수정 일시           |

---

### 설정 옵션

| 옵션명         | 타입    | 기본값   | 설명                       |
|----------------|---------|----------|----------------------------|
| apiVersion     | string  | v1       | API 버전                   |
| clusterConfig  | object  | 없음     | 쿠버네티스 클러스터 설정   |

---

#### 코드 스니펫 예시 (설정 파일)

```yaml
apiVersion: v1
clusterConfig:
  server: https://kubernetes.example.com
  certificate-authority-data: ...
  user:
    token: ...
```

---

## 쿠버네티스 클라이언트 유틸리티

### 주요 구성 요소

| 구성 요소            | 설명                                   |
|---------------------|----------------------------------------|
| K8sClientController | 클러스터 리소스 제어 요청 처리          |
| K8sClientService    | 리소스 관리 비즈니스 로직 수행           |
| K8sApiClient        | 쿠버네티스 API 서버와 직접 통신          |
| K8sConfigLoader     | 클러스터 접속 설정 로드 및 인증 정보 제공 |

---

### 데이터 모델 및 API 엔드포인트

- 데이터 모델, API 엔드포인트, 설정 항목에 대한 구체적 정의는 소스 코드에 존재하지 않습니다.

---

### 코드 스니펫 예시 (클러스터 설정 로드)

```python
class K8sConfigLoader:
    def load_config(self, path):
        with open(path) as f:
            return yaml.safe_load(f)
```

---

## 시퀀스 다이어그램: 오픈API 모델 생성 및 쿠버네티스 리소스 생성 요청

아래 시퀀스 다이어그램은 오픈API 모델 생성과 쿠버네티스 리소스 생성 요청의 처리 흐름을 보여줍니다.

```mermaid
sequenceDiagram
    participant Client
    participant OpenAPIController
    participant OpenAPIService
    participant OpenAPIRepository
    participant K8sClientController
    participant K8sClientService
    participant K8sApiClient
    participant K8sConfigLoader

    Client ->> OpenAPIController: POST /openapi/model
    OpenAPIController ->> OpenAPIService: 모델 생성 요청
    OpenAPIService ->> OpenAPIRepository: 모델 저장
    OpenAPIRepository -->> OpenAPIService: 저장 결과 반환
    OpenAPIService -->> OpenAPIController: 생성 결과 반환
    OpenAPIController -->> Client: 응답

    Client ->> K8sClientController: POST /k8s/resource
    K8sClientController ->> K8sClientService: 리소스 생성 요청
    K8sClientService ->> K8sConfigLoader: 클러스터 설정 로드
    K8sConfigLoader -->> K8sClientService: 설정 반환
    K8sClientService ->> K8sApiClient: API 서버에 리소스 생성 요청
    K8sApiClient -->> K8sClientService: 생성 결과 반환
    K8sClientService -->> K8sClientController: 응답
    K8sClientController -->> Client: 응답

    Note over OpenAPIController,K8sClientController: 각 Controller는 요청을 받아 Service로 위임합니다.
```

---

## 결론

쿠버네티스 연동 시스템은 오픈API 클라이언트 모델 관리와 쿠버네티스 클러스터 리소스 제어를 명확하게 분리된 계층 구조로 제공합니다. 각 계층은 역할에 따라 독립적으로 설계되어, 유지보수성과 확장성이 뛰어납니다. 본 시스템은 쿠버네티스 기반 서비스의 통합적 관리와 자동화를 위한 핵심 인프라로 활용될 수 있습니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('3820c7e3-a964-4caa-99b2-5f68a67cd326', e'# 쿠버네티스 오픈API 클라이언트 모델 및 API

## Introduction

본 프로젝트는 쿠버네티스(Kubernetes) 환경에서 오픈API 클라이언트 모델과 API를 구현하고 관리하는 시스템입니다. 주요 목적은 쿠버네티스 클러스터 내에서 오픈API 스펙에 따라 클라이언트 모델을 정의하고, 이를 통해 API 요청 및 응답을 효율적으로 처리하는 것입니다. 시스템은 Controller, Service, Data Access 등 계층별로 분리되어 있으며, 각 계층은 역할에 따라 명확히 구분되어 있습니다.

아래 다이어그램은 전체 시스템의 주요 의존성 흐름을 시각화한 것입니다.

**아키텍처 계층 및 흐름 다이어그램**

```mermaid
graph TD
    subgraph "Controller Layer"
        Controller["OpenAPIController"]
    end
    subgraph "Service Layer"
        Service["OpenAPIService"]
    end
    subgraph "Data Access Layer"
        Repository["OpenAPIRepository"]
    end
    subgraph "Domain Layer"
        Model["OpenAPIModel"]
    end
    subgraph "Configuration Layer"
        Config["OpenAPIConfig"]
    end
    Controller --> Service
    Service --> Repository
    Repository --> Model
    Service --> Config
```

*설명: Controller Layer에서 요청을 받아 Service Layer로 전달하며, Service Layer는 Data Access Layer 및 Configuration Layer와 상호작용합니다. Data Access Layer는 Domain Layer의 모델을 이용합니다.*

---

## 시스템 구성 요소 및 아키텍처

### Controller Layer

#### 주요 역할
- 클라이언트의 API 요청을 수신하고, Service Layer로 전달합니다.

#### 주요 클래스 및 함수
| 구성 요소           | 설명                           |
|---------------------|--------------------------------|
| OpenAPIController   | API 엔드포인트 요청 처리       |

---

### Service Layer

#### 주요 역할
- 비즈니스 로직을 처리하며, 데이터 접근 및 설정 정보를 관리합니다.

#### 주요 클래스 및 함수
| 구성 요소         | 설명                                 |
|-------------------|--------------------------------------|
| OpenAPIService    | API 요청의 핵심 로직 처리            |

---

### Data Access Layer

#### 주요 역할
- 데이터 모델과의 상호작용을 담당합니다.

#### 주요 클래스 및 함수
| 구성 요소           | 설명                           |
|---------------------|--------------------------------|
| OpenAPIRepository   | 데이터 저장소 접근 및 조작      |

---

### Domain Layer

#### 주요 역할
- 오픈API 클라이언트 모델의 데이터 구조를 정의합니다.

#### 주요 데이터 구조
| 모델명           | 설명                             |
|------------------|----------------------------------|
| OpenAPIModel     | 오픈API 요청/응답 데이터 모델    |

---

### Configuration Layer

#### 주요 역할
- 시스템의 설정 정보를 관리합니다.

#### 주요 구성 요소
| 구성 요소         | 설명                             |
|-------------------|----------------------------------|
| OpenAPIConfig     | API 및 시스템 설정 관리          |

---

## 데이터 흐름 및 로직

아래 다이어그램은 API 요청이 처리되는 전체 플로우를 보여줍니다.

```mermaid
graph TD
    subgraph "Controller Layer"
        Controller["OpenAPIController"]
    end
    subgraph "Service Layer"
        Service["OpenAPIService"]
    end
    subgraph "Data Access Layer"
        Repository["OpenAPIRepository"]
    end
    subgraph "Domain Layer"
        Model["OpenAPIModel"]
    end
    subgraph "Configuration Layer"
        Config["OpenAPIConfig"]
    end
    Controller --> Service
    Service --> Repository
    Repository --> Model
    Service --> Config
```

*설명: 클라이언트의 요청이 Controller에서 시작되어 Service를 거쳐 Repository 및 Model로 전달되며, 필요한 경우 Service는 Config에서 설정 정보를 조회합니다.*

---

## API 엔드포인트 및 데이터 모델

### API 엔드포인트

| 엔드포인트           | 메서드 | 파라미터 | 설명                     |
|----------------------|--------|----------|--------------------------|
| /openapi/models      | GET    | 없음     | 오픈API 모델 목록 조회   |
| /openapi/model/{id}  | GET    | id       | 특정 모델 상세 조회      |
| /openapi/model       | POST   | body     | 모델 생성                |
| /openapi/model/{id}  | PUT    | id, body | 모델 수정                |
| /openapi/model/{id}  | DELETE | id       | 모델 삭제                |

---

### 데이터 모델 필드

| 필드명     | 타입    | 제약 조건 | 설명                |
|------------|---------|-----------|---------------------|
| id         | string  | 필수      | 모델 식별자         |
| name       | string  | 필수      | 모델 이름           |
| spec       | object  | 필수      | 오픈API 스펙 정보   |
| createdAt  | string  | 선택      | 생성 일시           |
| updatedAt  | string  | 선택      | 수정 일시           |

---

### 설정 옵션

| 옵션명         | 타입    | 기본값   | 설명                       |
|----------------|---------|----------|----------------------------|
| apiVersion     | string  | v1       | API 버전                   |
| clusterConfig  | object  | 없음     | 쿠버네티스 클러스터 설정   |

---

## 결론

본 시스템은 쿠버네티스 환경에서 오픈API 클라이언트 모델 및 API를 계층적으로 구조화하여 관리합니다. 각 계층은 명확한 역할을 가지며, 데이터 흐름과 설정 관리가 체계적으로 이루어집니다. 이를 통해 API의 확장성과 유지보수성을 높일 수 있습니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('ea400d05-4b5f-4788-bed0-36a68bc328f8', e'# 쿠버네티스 클라이언트 유틸리티

## 소개

쿠버네티스 클라이언트 유틸리티는 쿠버네티스 클러스터와 상호작용하기 위한 클라이언트 기능을 제공합니다. 이 유틸리티는 클러스터 내 리소스의 조회, 생성, 수정, 삭제 등 다양한 작업을 프로그래밍적으로 수행할 수 있도록 지원합니다. 주요 목적은 개발자가 쿠버네티스 API와 직접 통신하지 않고도, 추상화된 인터페이스를 통해 효율적으로 클러스터를 제어할 수 있게 하는 데 있습니다.

아래 다이어그램은 전체 시스템의 주요 레이어와 의존성 흐름을 시각화한 것입니다.

### 아키텍처 다이어그램

아래 다이어그램은 쿠버네티스 클라이언트 유틸리티의 주요 레이어와 구성 요소 간의 호출 흐름을 나타냅니다.

```mermaid
graph TD
    subgraph "Controller Layer"
        Controller["K8sClientController"]
    end
    subgraph "Service Layer"
        Service["K8sClientService"]
    end
    subgraph "Data Access Layer"
        ApiClient["K8sApiClient"]
        ConfigLoader["K8sConfigLoader"]
    end
    Controller --> Service
    Service --> ApiClient
    Service --> ConfigLoader
```

**설명:**
Controller Layer는 외부 요청을 받아 Service Layer로 전달합니다. Service Layer는 비즈니스 로직을 처리하며, Data Access Layer의 ApiClient 및 ConfigLoader를 통해 실제 쿠버네티스 API와 통신하거나 설정을 로드합니다.

---

## 주요 구성 요소 및 아키텍처

### Controller Layer

#### K8sClientController

- **역할:** 외부 요청을 받아 Service Layer로 전달합니다.
- **주요 기능:** 클러스터 리소스 조회, 생성, 수정, 삭제 요청 처리

| 구성 요소              | 설명                                 |
|----------------------|------------------------------------|
| K8sClientController  | 클라이언트 요청을 받아 서비스에 위임 |

---

### Service Layer

#### K8sClientService

- **역할:** 비즈니스 로직을 처리하고, Data Access Layer와 상호작용합니다.
- **주요 기능:** 리소스 관리 로직, 예외 처리, 데이터 변환 등

| 구성 요소            | 설명                                   |
|--------------------|--------------------------------------|
| K8sClientService   | 리소스 관리 비즈니스 로직 수행             |

---

### Data Access Layer

#### K8sApiClient

- **역할:** 쿠버네티스 API 서버와 직접 통신합니다.
- **주요 기능:** REST API 호출, 리소스 CRUD

#### K8sConfigLoader

- **역할:** 쿠버네티스 클러스터 접속 설정을 로드합니다.
- **주요 기능:** kubeconfig 파일 파싱, 인증 정보 제공

| 구성 요소         | 설명                                   |
|-----------------|--------------------------------------|
| K8sApiClient    | 쿠버네티스 API 서버와 직접 통신             |
| K8sConfigLoader | 클러스터 접속 설정 로드 및 인증 정보 제공     |

---

## 데이터 흐름

1. Controller가 외부 요청을 수신합니다.
2. Service Layer로 요청을 위임합니다.
3. Service Layer는 Data Access Layer의 ApiClient 또는 ConfigLoader를 호출하여 실제 작업을 수행합니다.
4. 결과를 Controller에 반환합니다.

---

## 데이터 모델 및 설정

**(소스 코드에 데이터 모델, API 엔드포인트, 설정 항목 등 구체적 정보가 없는 경우, 해당 정보가 부재함을 명시합니다.)**

- 데이터 모델, API 엔드포인트, 설정 항목에 대한 구체적 정의는 소스 코드에 존재하지 않습니다.

---

## 결론

쿠버네티스 클라이언트 유틸리티는 Controller, Service, Data Access의 3계층 구조로 설계되어 있습니다. 각 계층은 명확한 역할 분담을 통해 유지보수성과 확장성을 높였습니다. 본 유틸리티는 쿠버네티스 클러스터와의 효율적인 통신 및 리소스 관리를 지원하는 핵심 도구입니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');
INSERT INTO public.contents (id, content, rel_src_files, created_at, created_by, updated_at, updated_by, page_id, version) VALUES ('6f28f36e-f65b-476f-a7c2-5c307df5784a', e'# 로깅 프레임워크 통합

## 소개

로깅 프레임워크 통합 프로젝트는 애플리케이션 내 다양한 계층에서 발생하는 로그 데이터를 일관성 있게 수집, 처리, 저장할 수 있도록 로깅 시스템을 통합하는 것을 목표로 합니다. 이 시스템은 Controller, Service, Data Access 등 주요 계층별로 로깅 책임을 분리하여, 각 계층에서 발생하는 이벤트와 오류를 효과적으로 추적할 수 있도록 설계되었습니다.

아래의 Mermaid.js 아키텍처 다이어그램은 전체 시스템의 의존성 흐름을 시각적으로 나타냅니다. 각 계층별로 역할이 구분되어 있으며, 로깅 프레임워크가 어떻게 통합되는지 한눈에 확인하실 수 있습니다.

### 아키텍처 다이어그램

아래 다이어그램은 Controller, Service, Data Access, Configuration 계층 간의 의존성과 로깅 프레임워크 통합 흐름을 보여줍니다.

```mermaid
graph TD
    subgraph "Controller Layer"
        Controller["MainController"]
    end
    subgraph "Service Layer"
        Service["LoggingService"]
    end
    subgraph "Data Access Layer"
        Repository["LogRepository"]
    end
    subgraph "Configuration"
        Config["LoggingConfig"]
    end

    Controller --> Service
    Service --> Repository
    Service --> Config
    Repository --> Config
```
*설명: Controller는 Service를 호출하며, Service는 로그 저장을 위해 Repository와 설정 정보를 참조합니다. 모든 계층은 LoggingConfig를 통해 통합 설정을 공유합니다.*

---

## 구성 요소 및 아키텍처

### Controller Layer

#### MainController

- 역할: 외부 요청을 받아 비즈니스 로직(Service Layer)로 전달합니다.
- 주요 책임: 요청 처리, 예외 발생 시 로깅 호출.

### Service Layer

#### LoggingService

- 역할: 로깅 로직의 중심 역할을 하며, 로그 메시지 생성 및 저장을 담당합니다.
- 주요 책임: 로그 데이터 가공, 저장 요청, 설정 정보 활용.

### Data Access Layer

#### LogRepository

- 역할: 로그 데이터를 실제 저장소(파일, DB 등)에 기록합니다.
- 주요 책임: 로그 데이터의 영속화.

### Configuration

#### LoggingConfig

- 역할: 전체 로깅 프레임워크의 설정 정보를 제공합니다.
- 주요 책임: 로깅 레벨, 출력 포맷, 저장 위치 등 설정값 관리.

---

## 데이터 흐름 및 로직

1. Controller에서 이벤트(예: 요청, 예외)가 발생하면 LoggingService에 로그 기록을 요청합니다.
2. LoggingService는 로그 메시지를 생성하고, 필요 시 LoggingConfig에서 설정값을 조회합니다.
3. LoggingService는 LogRepository를 호출하여 로그를 저장합니다.
4. LogRepository는 설정에 따라 로그를 저장소에 기록합니다.

---

## 주요 구성 요소 요약

| 구성 요소        | 계층             | 설명                                      |
|------------------|------------------|-------------------------------------------|
| MainController   | Controller Layer | 외부 요청 처리 및 로깅 트리거             |
| LoggingService   | Service Layer    | 로그 메시지 생성 및 저장 로직             |
| LogRepository    | Data Access Layer| 로그 데이터 영속화                        |
| LoggingConfig    | Configuration    | 로깅 설정값 제공                          |

---

## 설정 항목 요약

| 설정 항목        | 타입    | 기본값   | 설명                        |
|------------------|---------|----------|-----------------------------|
| logLevel         | String  | INFO     | 로그 레벨(예: INFO, ERROR)  |
| logFormat        | String  | JSON     | 로그 출력 포맷              |
| logDestination   | String  | file.log | 로그 저장 위치              |

---

## 결론

로깅 프레임워크 통합 시스템은 각 계층별로 명확한 역할 분담과 설정 일원화를 통해, 로그 데이터의 일관성 있는 수집과 관리가 가능합니다. 이를 통해 장애 추적, 운영 모니터링, 보안 감사 등 다양한 목적의 로그 활용이 용이해집니다.', '{}', '2025-06-20 02:27:27.105218 +00:00', null, '2025-06-20 02:27:27.105218 +00:00', null, null, '1.0.0');

-- service_codes 테이블 데이터 추가
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('module_status', '에이전트 상태', '', 1, 1, '에이전트 상태', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('success', '에이전트 상태', 'module_status', 1, 2, '에이전트 상태', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('waiting', '대기중', 'module_status', 2, 2, '에이전트 상태', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('processing', '처리중', 'module_status', 3, 2, '에이전트 상태', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('failed', '에이전트 상태', 'module_status', 4, 2, '에이전트 상태', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('requirement_agent', '요구사항 분석 에이전트', 'analysis_agents', 1, 3, '요구사항 분석 에이전트', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('infra_design_agent', '인프라 설계 에이전트', 'design_agents', 1, 3, '인프라 설계 에이전트', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('sw_design_agent', '소프트웨어 설계 에이전트', 'design_agents', 2, 3, '소프트웨어 디자인 에이전트', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('code_analysis_agent', '코드 분석 에이전트', 'implement_agents', 1, 3, '요구사항 분석 에이전트', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('migration_agent', '요구사항 분석 에이전트', 'implement_agents', 2, 3, '요구사항 분석 에이전트', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('test_agent', '테스트 에이전트', 'test_agents', 1, 3, '요구사항 분석 에이전트', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('agent_groups', '에이전트 그룹', '', 1, 1, '에이전트 그룹들의 목록 입니다', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('analysis_agents', '분석', 'agent_groups', 1, 2, '분석 에이전트 그룹 입니다', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('design_agents', '설계', 'agent_groups', 2, 2, '설계 에이전트 그룹 입니다', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('implement_agents', '구현', 'agent_groups', 3, 2, '구현 에이전트 그룹 입니다', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
INSERT INTO public.service_codes (code, value, parent_code, "order", depth, description, efct_st_dt, efct_fns_dt, created_at, created_by, updated_at, updated_by) VALUES ('test_agents', '테스트', 'agent_groups', 4, 2, '테스트 에이전트 그룹 입니다', '2025-07-10 00:00:00.000000', '9999-12-31 00:00:00.000000', '2025-07-10 06:01:27.095356', null, '2025-07-10 06:01:27.095356', null);
