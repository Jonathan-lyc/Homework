// Mutual exclusion lock.
struct lock_t {
  uint locked;       // Is the lock held?
  
  // For debugging:
  struct cpu *cpu;   // The cpu holding the lock.
  uint pcs[10];      // The call stack (an array of program counters)
                     // that locked the lock.
};

void lock_acquire(struct lock_t *lock);
void lock_release(struct lock_t *lock);
void lock_init(struct lock_t *lock);