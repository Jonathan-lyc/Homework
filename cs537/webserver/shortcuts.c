#include "shortcuts.h"

/* $begin unixerror */
//void unix_error(char *msg) /* unix-style error */
//{
    //fprintf(stderr, "%s: %s\n", msg, strerror(errno));
    //exit(0);
//}

/* $begin wrapper functions */
void Mutex_init(pthread_mutex_t *lock) {
	int rc = pthread_mutex_init(lock, NULL);
	if (rc != 0) {
		unix_error("mutex initialization error");
	}
}
void Mutex_lock(pthread_mutex_t *lock) {
	int rc = pthread_mutex_lock(lock);
	if (rc != 0) {
	    unix_error("mutex lock error"); 
	}
}
void Mutex_unlock(pthread_mutex_t *lock) {
	int rc = pthread_mutex_unlock(lock);
	if (rc != 0) {
	    unix_error("mutex unlock error"); 
	}
}

// Condition variables
void Cond_init(pthread_cond_t *cond) {
    int rc = pthread_cond_init(cond, NULL);
	if (rc != 0) {
	    unix_error("conditional variable initialization error"); 
	}
}
void Cond_wait(pthread_cond_t *cond, void *lock) {
	int rc = pthread_cond_wait(cond, lock);
	if (rc != 0) {
		unix_error("conditional variable wait error");
	}
}
void Cond_signal(pthread_cond_t *cond) {
	int rc = pthread_cond_signal(cond);
	if (rc != 0) {
		unix_error("conditional variable signal error");
	}
}

// Thread shortcuts

void Pthread_create(pthread_t *cid, void *func) {
	int rc = pthread_create(cid, NULL, func, NULL);
	if (rc != 0) {
		unix_error("pthread create error");
	}
}
void Pthread_join(pthread_t *cid) {
	int rc = pthread_join(*cid, NULL);
	if (rc != 0) {
		unix_error("pthread join error");
	}
}

int timeval_subtract(struct timeval *result, struct timeval *t2, struct timeval *t1) {
    long int diff = (t2->tv_usec + 1000000 * t2->tv_sec) - (t1->tv_usec + 1000000 * t1->tv_sec);
    result->tv_sec = diff / 1000000;
    result->tv_usec = diff % 1000000;

    return (diff<0);
}