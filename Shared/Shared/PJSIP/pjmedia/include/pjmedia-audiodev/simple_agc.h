#ifndef simple_agc_h__
#define simple_agc_h__

/* init sagc module
 * wnd_size : frame counts in buf window
 * threshold_db : don't increase sound when frame's max amplitude < threshold_db
 * gain_db : value add to sound's sample point 
 */

typedef struct sagc_handle sagc_handle;

sagc_handle *init_sagc(int wnd_size, int threshold_db, int gain_db);

void free_sagc(sagc_handle *handle);

/* exec agc in sample frame
 * data : frame buf
 * size : frame buf size
 */
void sagc_get_frame(sagc_handle *handle, short *data, int size);
#endif
