<<<<<<< HEAD
=======

>>>>>>> d2fde116ec48de7cdd2c93c7ff852824130cc81a
// Mutual exclusion lock.
struct lock_t {
  uint locked;       // Is the lock held?
};

void lock_acquire(struct lock_t *lock);
void lock_release(struct lock_t *lock);
void lock_init(struct lock_t *lock);
int  lock_holding(struct lock_t *lock);
<<<<<<< HEAD
int  thread_create(void *(*start_routine)(void*), void *arg);
=======
void thread_create(void *(*start_routine)(void*), void *arg);
>>>>>>> d2fde116ec48de7cdd2c93c7ff852824130cc81a
