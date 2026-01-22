-- CreateEnum
CREATE TYPE "public"."UserRole" AS ENUM ('admin', 'staff', 'student');

-- CreateEnum
CREATE TYPE "public"."UserStatus" AS ENUM ('active', 'inactive', 'suspended');

-- CreateEnum
CREATE TYPE "public"."AttendanceStatus" AS ENUM ('present', 'absent', 'late', 'excused');

-- CreateEnum
CREATE TYPE "public"."AttendanceMethod" AS ENUM ('qr', 'manual', 'hybrid');

-- CreateEnum
CREATE TYPE "public"."SessionType" AS ENUM ('lecture', 'lab', 'tutorial', 'exam');

-- CreateEnum
CREATE TYPE "public"."PlanningStatus" AS ENUM ('planned', 'in_progress', 'completed');

-- CreateEnum
CREATE TYPE "public"."JustificationReason" AS ENUM ('medical', 'family', 'emergency', 'academic', 'other');

-- CreateEnum
CREATE TYPE "public"."JustificationStatus" AS ENUM ('pending', 'approved', 'rejected');

-- CreateEnum
CREATE TYPE "public"."DepartmentType" AS ENUM ('Technology', 'Engineering', 'Science', 'Arts', 'Business', 'Other');

-- CreateEnum
CREATE TYPE "public"."DepartmentStatus" AS ENUM ('Active', 'Inactive');

-- CreateEnum
CREATE TYPE "public"."NotificationType" AS ENUM ('absence_reminder', 'justification_status', 'attendance_alert', 'class_reminder');

-- CreateEnum
CREATE TYPE "public"."NotificationPriority" AS ENUM ('low', 'normal', 'high', 'urgent');

-- CreateEnum
CREATE TYPE "public"."RiskLevel" AS ENUM ('low', 'medium', 'high', 'critical');

-- CreateEnum
CREATE TYPE "public"."AlertType" AS ENUM ('notification', 'email', 'parent_email', 'parent_sms');

-- CreateEnum
CREATE TYPE "public"."AlertStatus" AS ENUM ('pending', 'sent', 'failed');

-- CreateTable
CREATE TABLE "public"."users" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "role" "public"."UserRole" NOT NULL,
    "status" "public"."UserStatus" NOT NULL DEFAULT 'active',
    "phone" TEXT,
    "avatar_url" TEXT,
    "last_seen" TIMESTAMP(3),
    "last_login" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."admins" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "admin_level" TEXT NOT NULL DEFAULT 'system',
    "permissions" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "admins_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."staff" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "employee_id" TEXT NOT NULL,
    "department" TEXT,
    "position" TEXT,
    "join_date" DATE,
    "salary" DECIMAL(10,2),
    "office_location" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "staff_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."students" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "student_id" TEXT NOT NULL,
    "class" TEXT,
    "section" TEXT,
    "year" TEXT,
    "enrollment_date" DATE,
    "gpa" DECIMAL(3,2) DEFAULT 0.00,
    "parent_email" TEXT,
    "parent_phone" TEXT,
    "address" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "students_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."classes" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "description" TEXT,
    "faculty_id" INTEGER,
    "room" TEXT,
    "capacity" INTEGER DEFAULT 50,
    "schedule" TEXT,
    "department" TEXT,
    "semester" TEXT,
    "academic_year" TEXT,
    "credits" INTEGER DEFAULT 3,
    "class_type" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "geofence_radius" INTEGER DEFAULT 100,
    "geofence_enabled" BOOLEAN DEFAULT true,
    "status" TEXT DEFAULT 'active',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "classes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."class_enrollments" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "class_id" INTEGER NOT NULL,
    "enrollment_date" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT DEFAULT 'enrolled',
    "grade" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "class_enrollments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."attendance_records" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "class_id" INTEGER NOT NULL,
    "session_date" DATE NOT NULL,
    "session_time" TIME,
    "status" "public"."AttendanceStatus" NOT NULL,
    "check_in_time" TIMESTAMP(3),
    "method" "public"."AttendanceMethod" NOT NULL DEFAULT 'manual',
    "qr_session_id" TEXT,
    "scan_timestamp" TIMESTAMP(3),
    "is_justified" BOOLEAN NOT NULL DEFAULT false,
    "justification_id" INTEGER,
    "student_latitude" DOUBLE PRECISION,
    "student_longitude" DOUBLE PRECISION,
    "distance_from_class" DOUBLE PRECISION,
    "location_verified" BOOLEAN DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "recorded_by" INTEGER,

    CONSTRAINT "attendance_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."attendance_sessions" (
    "id" SERIAL NOT NULL,
    "session_id" TEXT NOT NULL,
    "class_id" INTEGER NOT NULL,
    "created_by" INTEGER NOT NULL,
    "session_date" DATE NOT NULL,
    "session_time" TIME NOT NULL,
    "session_type" "public"."SessionType" NOT NULL DEFAULT 'lecture',
    "location" TEXT,
    "planned_topic" TEXT,
    "target_learning" TEXT,
    "target_level" TEXT,
    "planning_status" "public"."PlanningStatus" NOT NULL DEFAULT 'planned',
    "notes" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "geofence_radius" INTEGER DEFAULT 100,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "status" TEXT DEFAULT 'active',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "attendance_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."qr_sessions" (
    "id" SERIAL NOT NULL,
    "session_id" TEXT NOT NULL,
    "attendance_session_id" INTEGER NOT NULL,
    "qr_data" TEXT NOT NULL,
    "scan_count" INTEGER NOT NULL DEFAULT 0,
    "max_scans" INTEGER,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "status" TEXT DEFAULT 'active',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "qr_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."absence_justifications" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "class_id" INTEGER NOT NULL,
    "attendance_record_id" INTEGER,
    "absence_date" DATE NOT NULL,
    "reason" "public"."JustificationReason" NOT NULL,
    "description" TEXT,
    "documents" JSONB,
    "status" "public"."JustificationStatus" NOT NULL DEFAULT 'pending',
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewed_at" TIMESTAMP(3),
    "reviewed_by" INTEGER,
    "review_note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "absence_justifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."departments" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "head_id" INTEGER,
    "type" "public"."DepartmentType" NOT NULL DEFAULT 'Other',
    "status" "public"."DepartmentStatus" NOT NULL DEFAULT 'Active',
    "programs_count" INTEGER NOT NULL DEFAULT 0,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."notifications" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "type" "public"."NotificationType" NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "priority" "public"."NotificationPriority" NOT NULL DEFAULT 'normal',
    "data" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3),

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."student_risk_tracking" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "risk_level" "public"."RiskLevel" NOT NULL,
    "attendance_rate" DECIMAL(5,2) NOT NULL,
    "consecutive_absences" INTEGER NOT NULL DEFAULT 0,
    "total_absences" INTEGER NOT NULL DEFAULT 0,
    "last_attendance_date" DATE,
    "parent_email" TEXT,
    "parent_phone" TEXT,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "student_risk_tracking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."student_alerts" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "alert_type" "public"."AlertType" NOT NULL,
    "message" TEXT NOT NULL,
    "recipient" TEXT,
    "status" "public"."AlertStatus" NOT NULL DEFAULT 'pending',
    "sent_by" INTEGER,
    "sent_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "student_alerts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."student_points" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "class_id" INTEGER,
    "points" INTEGER NOT NULL,
    "point_type" TEXT NOT NULL,
    "description" TEXT,
    "reference_id" INTEGER,
    "awarded_by" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "student_points_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."achievements" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT NOT NULL,
    "icon" TEXT,
    "points_reward" INTEGER NOT NULL DEFAULT 0,
    "requirement_type" TEXT,
    "requirement_value" INTEGER,
    "requirement_period" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "achievements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."student_achievements" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "achievement_id" INTEGER NOT NULL,
    "progress" INTEGER NOT NULL DEFAULT 0,
    "is_earned" BOOLEAN NOT NULL DEFAULT false,
    "earned_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "student_achievements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."student_streaks" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "class_id" INTEGER NOT NULL,
    "current_streak" INTEGER NOT NULL DEFAULT 0,
    "longest_streak" INTEGER NOT NULL DEFAULT 0,
    "last_attendance_date" DATE,
    "streak_start_date" DATE,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "student_streaks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."leaderboard_rankings" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "class_id" INTEGER,
    "department_id" INTEGER,
    "period" TEXT NOT NULL,
    "scope" TEXT NOT NULL,
    "rank_position" INTEGER NOT NULL,
    "total_points" INTEGER NOT NULL DEFAULT 0,
    "attendance_rate" DECIMAL(5,2),
    "streak_days" INTEGER NOT NULL DEFAULT 0,
    "achievements_count" INTEGER NOT NULL DEFAULT 0,
    "period_start" DATE NOT NULL,
    "period_end" DATE NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "leaderboard_rankings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."geofence_settings" (
    "id" SERIAL NOT NULL,
    "default_radius" INTEGER NOT NULL DEFAULT 100,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "allow_override" BOOLEAN NOT NULL DEFAULT true,
    "accuracy_threshold" DOUBLE PRECISION NOT NULL DEFAULT 50.0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "geofence_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."class_locations" (
    "id" SERIAL NOT NULL,
    "class_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "radius" INTEGER NOT NULL DEFAULT 100,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "class_locations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "public"."users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "admins_user_id_key" ON "public"."admins"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "staff_user_id_key" ON "public"."staff"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "staff_employee_id_key" ON "public"."staff"("employee_id");

-- CreateIndex
CREATE UNIQUE INDEX "students_user_id_key" ON "public"."students"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "students_student_id_key" ON "public"."students"("student_id");

-- CreateIndex
CREATE UNIQUE INDEX "classes_code_key" ON "public"."classes"("code");

-- CreateIndex
CREATE UNIQUE INDEX "class_enrollments_student_id_class_id_key" ON "public"."class_enrollments"("student_id", "class_id");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_records_student_id_class_id_session_date_key" ON "public"."attendance_records"("student_id", "class_id", "session_date");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_sessions_session_id_key" ON "public"."attendance_sessions"("session_id");

-- CreateIndex
CREATE UNIQUE INDEX "qr_sessions_session_id_key" ON "public"."qr_sessions"("session_id");

-- CreateIndex
CREATE UNIQUE INDEX "departments_code_key" ON "public"."departments"("code");

-- CreateIndex
CREATE UNIQUE INDEX "student_achievements_student_id_achievement_id_key" ON "public"."student_achievements"("student_id", "achievement_id");

-- CreateIndex
CREATE UNIQUE INDEX "student_streaks_student_id_class_id_key" ON "public"."student_streaks"("student_id", "class_id");

-- CreateIndex
CREATE UNIQUE INDEX "leaderboard_rankings_student_id_period_scope_period_start_key" ON "public"."leaderboard_rankings"("student_id", "period", "scope", "period_start");

-- AddForeignKey
ALTER TABLE "public"."admins" ADD CONSTRAINT "admins_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."staff" ADD CONSTRAINT "staff_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."students" ADD CONSTRAINT "students_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."classes" ADD CONSTRAINT "classes_faculty_id_fkey" FOREIGN KEY ("faculty_id") REFERENCES "public"."staff"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."class_enrollments" ADD CONSTRAINT "class_enrollments_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."class_enrollments" ADD CONSTRAINT "class_enrollments_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."attendance_records" ADD CONSTRAINT "attendance_records_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."attendance_records" ADD CONSTRAINT "attendance_records_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."attendance_records" ADD CONSTRAINT "attendance_records_recorded_by_fkey" FOREIGN KEY ("recorded_by") REFERENCES "public"."staff"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."attendance_sessions" ADD CONSTRAINT "attendance_sessions_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."attendance_sessions" ADD CONSTRAINT "attendance_sessions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."qr_sessions" ADD CONSTRAINT "qr_sessions_attendance_session_id_fkey" FOREIGN KEY ("attendance_session_id") REFERENCES "public"."attendance_sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."absence_justifications" ADD CONSTRAINT "absence_justifications_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."absence_justifications" ADD CONSTRAINT "absence_justifications_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."absence_justifications" ADD CONSTRAINT "absence_justifications_attendance_record_id_fkey" FOREIGN KEY ("attendance_record_id") REFERENCES "public"."attendance_records"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."absence_justifications" ADD CONSTRAINT "absence_justifications_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "public"."staff"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."departments" ADD CONSTRAINT "departments_head_id_fkey" FOREIGN KEY ("head_id") REFERENCES "public"."staff"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_risk_tracking" ADD CONSTRAINT "student_risk_tracking_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_alerts" ADD CONSTRAINT "student_alerts_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_alerts" ADD CONSTRAINT "student_alerts_sent_by_fkey" FOREIGN KEY ("sent_by") REFERENCES "public"."staff"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_points" ADD CONSTRAINT "student_points_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_points" ADD CONSTRAINT "student_points_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_achievements" ADD CONSTRAINT "student_achievements_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_achievements" ADD CONSTRAINT "student_achievements_achievement_id_fkey" FOREIGN KEY ("achievement_id") REFERENCES "public"."achievements"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_streaks" ADD CONSTRAINT "student_streaks_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."student_streaks" ADD CONSTRAINT "student_streaks_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."leaderboard_rankings" ADD CONSTRAINT "leaderboard_rankings_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."leaderboard_rankings" ADD CONSTRAINT "leaderboard_rankings_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."leaderboard_rankings" ADD CONSTRAINT "leaderboard_rankings_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "public"."departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."class_locations" ADD CONSTRAINT "class_locations_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE ON UPDATE CASCADE;
